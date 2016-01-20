#!/usr/bin/python3
''' Update images '''

import argparse
import itertools
import json
import os
import queue
import subprocess
import sys
import threading

import networkx
import requests
import yaml

import unixconn

PATH_REPO = subprocess.run([
    '/usr/bin/git', '-C', os.path.dirname(os.path.realpath(__file__)),
    'rev-parse', '--show-toplevel'
], stdout=subprocess.PIPE, check=True).stdout.decode('UTF-8').rstrip('\n')
PATH_IMAGES = os.path.join(PATH_REPO, 'images')

IMAGES = yaml.load(open(os.path.join(PATH_REPO, 'images.yaml')), Loader=yaml.CLoader)
META = IMAGES['meta']
del IMAGES['meta']
for IMAGE in IMAGES.copy():
    IMAGES['{0:s}/{1:s}'.format(META['name'], IMAGE)] = IMAGES.pop(IMAGE)

DOCKERURL = 'http+docker://localunixsocket'
DOCKERCONN = requests.Session()
DOCKERCONN.mount(
    'http+docker://',
    unixconn.UnixAdapter('http+unix://run/docker.sock', META['limits']['timeout']),
)


def args_parse(args=None):
    ''' Parse arguments '''
    parser = argparse.ArgumentParser(description='Docker container updater')

    # Optional
    parser.add_argument('--no-cache', action='store_true', help='Force image update')
    parser.add_argument('--no-scratch', action='store_true', help='Do not build scratch')
    parser.add_argument('--no-successors', action='store_true', help='Do not build successors')

    # Positional
    parser.add_argument('images', metavar='IMAGE', action='store', nargs='*', help='Name of image')

    args = parser.parse_args() if not args else parser.parse_args(args)

    # Check if images present in config
    failed = False
    for image in args.images:
        if image not in IMAGES:
            print('ERROR: image not in config: {0:s}'.format(image), file=sys.stderr)
            failed = True
    if failed:
        sys.exit(2)

    return args

ARGS = args_parse()


def dockerfile_from(path):
    ''' return FROM '''
    with open(path) as filedesc:
        for line in filedesc:
            if line.startswith('FROM'):
                return line.split()[-1]


def path_image(image):
    ''' return path to image '''
    return os.path.join(PATH_IMAGES, image.split('/')[-1].replace(':', '/'))


class Build:
    ''' Image build '''
    def __init__(self, image):
        self.image = image
        self.log = ''
        self.state = False

    def scratch(self, image):
        ''' Build scratch '''
        if IMAGES[image]['scratch']['call'].startswith('/'):
            cmd = [IMAGES[image]['scratch']['call']]
        else:
            cmd = [os.path.join(PATH_REPO, IMAGES[image]['scratch']['call'])]
        cmd += IMAGES[image]['scratch']['args']

        try:
            self.log += subprocess.run(
                cmd, check=True, stdout=subprocess.PIPE).stdout.decode('UTF-8')
        except subprocess.CalledProcessError as error:
            self.log += 'ERROR: Build.scratch: {0:s}\n'.format(str(error))
            return False

        return True

    def tar(self, path):
        ''' Tar path '''
        try:
            data = subprocess.run([
                '/usr/bin/tar', '--create', '--file=-',
                '--owner=root', '--group=root',
                '--directory={0:s}'.format(path),
                '.',
            ], check=True, stdout=subprocess.PIPE).stdout
        except subprocess.CalledProcessError as error:
            self.log += 'ERROR: Build.tar: {0:s}\n'.format(str(error))
            return None

        return data

    def post(self, payload):
        ''' Build image '''
        try:
            response = DOCKERCONN.post(
                '{0:s}/build'.format(DOCKERURL),
                headers={'Content-Type': 'application/tar'},
                params={**{'t': self.image, 'nocache': ARGS.no_cache}, **META['params']},
                data=payload,
                stream=True,
                timeout=META['limits']['timeout']
            )
        except requests.exceptions.Timeout as error:
            self.log += 'ERROR: Build.post timeout: {0:s}\n'.format(str(error))
            return None
        if response.status_code != 200:
            self.log += 'ERROR: Build.post: {0:d}: {1:s}\n'.format(
                response.status_code, response.content.decode('UTF-8').rstrip())
            return None

        return response


def json_decode_build(string):
    ''' Decode json data from response '''
    decoded = ''
    try:
        deserial = json.loads(string)
    except json.decoder.JSONDecodeError as error:
        raise RuntimeError(str(error))
    if not isinstance(deserial, dict):
        raise RuntimeError('Loaded JSON string is not a dictionary')

    if 'stream' in deserial:
        decoded += deserial['stream']
        del deserial['stream']
    if deserial:
        decoded += str(deserial) + '\n'

    if 'error' in deserial:
        return False, decoded
    return True, decoded


class ThreadBuild(threading.Thread):
    ''' Image builder '''
    def __init__(self, queue_in, queue_out):
        threading.Thread.__init__(self, daemon=True)
        self._stop = threading.Event()
        self.queue_in = queue_in
        self.queue_out = queue_out

    def _return(self, build):
        self.queue_out.put(build)
        self.queue_in.task_done()

    def stop(self):
        ''' Stop thread '''
        self._stop.set()

    def stopped(self):
        ''' Is thread stopped '''
        return self._stop.is_set()

    def run(self):
        while True:
            try:
                image = self.queue_in.get(timeout=0.1)
            except queue.Empty:
                if self.stopped():
                    return
                continue

            build = Build(image)

            if 'scratch' in IMAGES[build.image] and not ARGS.no_scratch:
                print('\033[33m### Building scratch: {0:s} ###\033[0m'.format(build.image))
                if not build.scratch(build.image):
                    self._return(build)
                    continue

            print('\033[33m### Building image: {0:s} ###\033[0m'.format(build.image))
            tar = build.tar(path_image(build.image))
            if not tar:
                self._return(build)
                continue

            response = build.post(tar)
            del tar
            if not response:
                self._return(build)
                continue

            failed = False
            for line in response.iter_lines():
                line = line.decode('UTF-8')

                try:
                    status, decoded = json_decode_build(line)
                except RuntimeError as error:
                    build.log += '{0:s}\n{1:s}\n'.format(str(error), line)
                    failed = True
                    continue

                build.log += decoded
                if not status:
                    failed = True

            if not failed:
                build.state = True

            self._return(build)


class FromTree:
    ''' FromTree '''
    def __init__(self, images_dict):
        self.graph = networkx.DiGraph()
        for image, image_dict in images_dict.items():
            image_dict['from'] = dockerfile_from(os.path.join(path_image(image), 'Dockerfile'))
            if image_dict['from'] == 'scratch':
                self.graph.add_node(image)
            else:
                self.graph.add_edge(image_dict['from'], image)

    def prune_disabled(self, images_dict, saveset):
        ''' Prune disabled images '''
        disabled = {
            image: self.graph.out_degree(image)
            for image in images_dict
            if not images_dict[image]['build']
        }
        remove = set()
        for image in sorted(disabled.keys(), key=lambda image: disabled[image]):
            if image in saveset:
                continue
            for predecessor in self.graph.predecessors_iter(image):
                if predecessor in disabled:
                    disabled[predecessor] -= 1
            if disabled[image] == 0:
                remove.add(image)
        self.graph.remove_nodes_from(remove)

    def successors(self):
        ''' Add successors attributes to nodes '''
        for image in self.graph.nodes_iter():
            self.graph.node[image]['successors'] = [
                successor
                for values in networkx.dfs_successors(self.graph, source=image).values()
                for successor in values
            ]
            self.graph.node[image]['successors_len'] = len(self.graph.node[image]['successors'])

    def prune(self, imageset, successors):
        ''' Prune all nodes except images
            Prune successors if True '''
        if successors:
            self.graph.remove_nodes_from(set(self.graph.nodes()) - imageset)
        else:
            self.graph.remove_nodes_from(set(self.graph.nodes()) - set(
                itertools.chain.from_iterable(
                    ([image] + self.graph.node[image]['successors'] for image in imageset))
            ))

    def build(self, threads_max):
        ''' Build '''
        queue_out = queue.Queue(maxsize=threads_max)
        queue_in = queue.Queue()
        threads = []
        for _ in range(threads_max):
            thread = ThreadBuild(queue_out, queue_in)
            threads.append(thread)
            thread.start()

        active = set()
        while self.graph:
            degrees = self.graph.in_degree()
            for image in sorted(
                    (image for image in degrees if image not in active and degrees[image] == 0),
                    reverse=True, key=lambda image: self.graph.node[image]['successors_len']):
                try:
                    queue_out.put(image, block=False)
                except queue.Full:
                    break
                active.add(image)

            build = queue_in.get()
            active.remove(build.image)

            print('\n\033[33m### Build log: {0:s} ###\033[0m'.format(build.image))
            print(build.log, end='')
            if build.state:
                print('\033[32m### Build finished: {0:s} ###\033[0m\n'.format(build.image))
                self.graph.remove_node(build.image)
            else:
                print('\033[31m### Build failed: {0:s} ###\033[0m\n'.format(build.image))
                successors = networkx.dfs_successors(self.graph, source=build.image)
                if successors:
                    self.graph.remove_nodes_from(set(
                        [image for key, values in successors.items() for image in [key]+values]
                    ))
                else:
                    self.graph.remove_node(build.image)

            queue_in.task_done()

        for thread in threads:
            thread.stop()


def main():
    ''' Main '''
    print('\n### Parsing Dockerfiles ###')
    fromtree = FromTree(IMAGES)
    fromtree.prune_disabled(IMAGES, ARGS.images)
    fromtree.successors()
    if ARGS.images:
        fromtree.prune(ARGS.images, successors=ARGS.no_successors)

    print('\n### Building images ###')
    fromtree.build(META['limits']['threads'])

    if not ARGS.images:
        print('\n### Cleaning up dangling images ###')
        response = DOCKERCONN.get(
            '{0:s}/images/json'.format(DOCKERURL),
            headers={'Content-Type': 'application/json'},
            params={'filters': json.dumps({'dangling': ['true']})},
            timeout=META['limits']['timeout'],
        )
        if response.status_code != 200:
            print('ERROR: main get /images/json: {0:d}: {1:s}'.format(
                response.status_code, response.content.decode('UTF-8').rstrip()))
            sys.exit(1)

        for image in response.json():
            response = DOCKERCONN.delete(
                '{0:s}/images/{1:s}'.format(DOCKERURL, image['Id']),
                headers={'Content-Type': 'application/json'},
                timeout=META['limits']['timeout'],
            )
            if response.status_code == 200:
                for dictionary in response.json():
                    print(dictionary['Deleted'])
            else:
                print('ERROR: delete /images/: {0:d}: {1:s}'.format(
                    response.status_code, response.content.decode('UTF-8').rstrip()))

if __name__ == '__main__':
    main()
