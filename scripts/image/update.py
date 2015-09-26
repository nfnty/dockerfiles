#!/usr/bin/python3
''' Update images '''

import argparse
import docker
import json
import networkx
import os
import pygit2
import queue
import subprocess
import threading
import yaml

CLIENT = docker.Client(base_url='unix://run/docker.sock', version='auto')

SCRIPTDIR = os.path.dirname(os.path.realpath(__file__))
REPODIR = pygit2.Repository(pygit2.discover_repository(SCRIPTDIR)).workdir
IMAGEDIR = os.path.join(REPODIR, 'images')

CONFIG = yaml.load(open(os.path.join(REPODIR, 'images.yaml')), Loader=yaml.CLoader,)
META = CONFIG['meta']
IMAGES = CONFIG.copy()
del IMAGES['meta']
del CONFIG

def args_parse():
    ''' Parse arguments '''
    parser = argparse.ArgumentParser(
        description='Docker container updater'
    )

    # Optional
    parser.add_argument(
        '--no-cache', action='store_true',
        help='Force image update'
    )
    parser.add_argument(
        '--no-scratch', action='store_true',
        help='Do not build scratch'
    )

    # Positional
    parser.add_argument(
        'images', metavar='IMAGE', action='store', nargs='*',
        help='Name of image',
    )

    args = parser.parse_args()
    args.images = ['{0:s}/{1:s}'.format(META['name'], image) for image in args.images]

    return args

ARGS = args_parse()

def dockerfile_from(path):
    ''' Return FROM '''
    with open(path, 'r') as fd:
        for line in fd:
            if line.startswith('FROM'):
                return line.split()[-1]

class Build:
    ''' Build class '''
    def __init__(self, name):
        self.name = name
        self.log = []
        self.state = 'waiting'
    def run(self):
        ''' Build image '''
        self.state = 'running'
        image = self.name.split('/')[-1]

        if 'scratch' in IMAGES[image] and not ARGS.no_scratch:
            print('\n\033[33m### Building scratch: {0:s} ###\033[0m'.format(self.name))
            try:
                self.log += subprocess.check_output(
                    [
                        IMAGES[image]['scratch']['call'] \
                        if IMAGES[image]['scratch']['call'].startswith('/') else \
                        os.path.join(REPODIR, IMAGES[image]['scratch']['call'])
                    ] +
                    IMAGES[image]['scratch']['args']
                ).decode('UTF-8').splitlines()
            except subprocess.CalledProcessError as error:
                self.state = 'failed'
                return

        print('\n\033[33m### Building image: {0:s} ###\033[0m'.format(self.name))
        generator = CLIENT.build(
            path=os.path.join(IMAGEDIR, image.replace(':', '/')),
            tag=self.name,
            container_limits={
                'memory': META['limits']['memory'],
                'memswap': META['limits']['memswap'],
                'cpushares': META['limits']['cpushares'],
            },
            nocache=ARGS.no_cache,
            rm=True,
        )
        try:
            for line in generator:
                self.log.append(json.loads(line.decode('UTF-8')))
            if 'error' in self.log[-1]:
                self.state = 'failed'
            else:
                self.state = 'finished'
        except docker.errors.APIError as error:
            self.log.append(str(error))
            self.state = 'failed'

class ThreadBuild(threading.Thread):
    ''' ThreadBuild class '''
    def __init__(self, queue_in, queue_out):
        threading.Thread.__init__(self, daemon=True)
        self.queue_in = queue_in
        self.queue_out = queue_out
    def run(self):
        while True:
            image = self.queue_in.get()
            build = Build(image)
            build.run()
            self.queue_out.put(build)
            self.queue_in.task_done()

class FromTree:
    ''' FromTree '''
    def __init__(self):
        ''' Initiate '''
        self.graph = networkx.DiGraph()
        for image, image_dict in IMAGES.items():
            image_full = '{0:s}/{1:s}'.format(META['name'], image)
            image_dict['from'] = dockerfile_from(
                os.path.join(IMAGEDIR, image.replace(':', '/'), 'Dockerfile')
            )
            if image_dict['from'] == 'scratch':
                self.graph.add_node(image_full)
            else:
                self.graph.add_edge(image_dict['from'], image_full)

        degrees = self.graph.out_degree()
        images = [
            image for image in degrees
            if not IMAGES[image.partition('/')[-1]]['build'] and degrees[image] == 0
        ]
        self.graph.remove_nodes_from(set(images))
    def prune(self, images):
        ''' Prune not in images '''
        nodes = {}
        for image in images:
            nodes[image] = []
            nodes.update(networkx.dfs_successors(self.graph, source=image))
        nodes = set([item for key, values in nodes.items() for item in [key]+values])
        self.graph.remove_nodes_from(set(self.graph.nodes()) - set(nodes))
    def successors(self):
        ''' Add attribute successors to all nodes '''
        successors = {}
        for image in self.graph.nodes_iter():
            successors[image] = len(set([
                successor
                for values in networkx.dfs_successors(self.graph, source=image).values()
                for successor in values
            ]))
        networkx.set_node_attributes(self.graph, 'successors', successors)
    def build(self):
        ''' Build '''
        queue_out = queue.Queue(maxsize=META['limits']['threads'])
        queue_in = queue.Queue()
        for _ in range(META['limits']['threads']):
            ThreadBuild(queue_out, queue_in).start()

        active = []
        while self.graph:
            degree = self.graph.in_degree()
            images = [image for image in degree if image not in active and degree[image] == 0]
            images = sorted(images, reverse=True,
                            key=lambda image: self.graph.node[image]['successors'])

            for image in images:
                try:
                    queue_out.put(image, block=False)
                except queue.Full:
                    break
                active.append(image)

            build = queue_in.get()
            active.remove(build.name)
            print('\n\033[33m### Build log: {0:s} ###\033[0m'.format(build.name))
            for line in build.log:
                if 'stream' in line:
                    print(line['stream'], end='')
                else:
                    print(line)
            if build.state == 'finished':
                print('\033[32m### Build finished: {0:s} ###\033[0m\n'.format(build.name))
                self.graph.remove_node(build.name)
            elif build.state == 'failed':
                print('\033[31m### Build failed: {0:s} ###\033[0m\n'.format(build.name))
                successors = networkx.dfs_successors(self.graph, source=build.name)
                if not successors:
                    self.graph.remove_node(build.name)
                else:
                    self.graph.remove_nodes_from(set(
                        [image for key, values in successors.items() for image in [key]+values]
                    ))
            else:
                raise RuntimeError('State is unknown: {0:s} {1:s}'.format(build.name, build.state))
            queue_in.task_done()

def main():
    ''' Main '''
    print('\n### Parsing Dockerfiles ###')
    fromtree = FromTree()
    if ARGS.images:
        fromtree.prune(ARGS.images)
    fromtree.successors()

    print('\n### Building images ###')
    fromtree.build()

    print('\n### Cleaning up dangling images ###')
    for image in CLIENT.images(quiet=True, filters={'dangling': True}):
        try:
            CLIENT.remove_image(image)
            print('Removed: {0:s}'.format(image))
        except docker.errors.APIError as error:
            print(str(error))

if __name__ == '__main__':
    main()
