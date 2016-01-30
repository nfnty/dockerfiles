#!/usr/bin/python3
''' Update images '''

import argparse
import json
import queue
import sys
import threading

from termcolor import cprint

from utils.api import request, delete, get, decode_build
from utils.image import IMAGES, META, Image, dockerfile_from
from utils.network import DiGraph


def args_parse(arguments=None):
    ''' Parse arguments '''
    parser = argparse.ArgumentParser(description='Update images')

    # Optional
    parser.add_argument('--no-cache', action='store_true', help='Force image update')
    parser.add_argument('--no-scratch', action='store_true', help='Do not build scratch')
    parser.add_argument('--no-successors', action='store_true', help='Do not build successors')

    # Positional
    parser.add_argument('images', metavar='IMAGE', action='store', nargs='*', help='Name of image')

    args = parser.parse_args(arguments)
    args.images = set(args.images)

    # Check if images present in config
    if not args.images <= set(IMAGES.keys()):
        cprint('image(s) not in config: {0:s}'.format(
            str(args.images - set(IMAGES.keys()))), 'red')
        sys.exit(2)

    return args


class ThreadBuild(threading.Thread):
    ''' Image builder '''
    def __init__(self, network, queue_in, queue_out):
        threading.Thread.__init__(self, daemon=True)
        self._stop = threading.Event()
        self.network = network
        self.queue_in = queue_in
        self.queue_out = queue_out

        self.name = None

    def _return(self, outcome, log):
        self.queue_out.put((self.name, outcome, log))
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
                _, self.name = self.queue_in.get(timeout=0.1)
            except queue.Empty:
                if self.stopped():
                    return
                continue

            image = self.network.node[self.name]['Object']
            log = ''

            if not ARGS.no_scratch and 'Scratch' in image.config:
                cprint('Building scratch: {0:s}'.format(self.name), 'yellow')
                try:
                    image.build_scratch()
                except RuntimeError as error:
                    log += 'Build scratch: {0:s}\n'.format(str(error))
                    self._return(False, log)
                    continue

            cprint('Building image: {0:s}'.format(self.name), 'yellow')
            try:
                response = image.build(ARGS.no_cache)
            except RuntimeError as error:
                log += 'Build: {0:s}\n'.format(str(error))
                self._return(False, log)
                continue

            failed = False
            for status, decoded in decode_build(response):
                log += decoded
                if not status:
                    failed = True
            if failed:
                self._return(False, log)
                continue

            self._return(True, log)


class Network(DiGraph):
    ''' Network of images '''
    def __init__(self, images_dict):
        super(Network, self).__init__()
        self.failed = set()

        for image, image_dict in images_dict.items():
            image_dict['From'] = dockerfile_from(image)
            self.add_node(image, {'Object': Image(image, image_dict)})
            if not image_dict['From'] == 'scratch':
                self.add_edge(image_dict['From'], image)

    def prune_disabled(self, images_dict, saveset):
        ''' Prune disabled images '''
        disabled = {image: self.out_degree(image) for image in images_dict
                    if not images_dict[image]['Build']}
        remove = set()
        for image in sorted(disabled.keys(), key=lambda image: disabled[image]):
            if image in saveset:
                continue
            for predecessor in self.predecessors_iter(image):
                if predecessor in disabled:
                    disabled[predecessor] -= 1
            if disabled[image] == 0:
                remove.add(image)
        self.remove_nodes_from(remove)

    def attr_successors(self):
        ''' Add successors attributes to nodes '''
        for node in self.nodes_iter():
            self.node[node]['Successors'] = self.successors_all(node)
            self.node[node]['SuccessorsLen'] = len(self.node[node]['Successors'])

    def build(self, threads_max):
        ''' Build '''
        queue_out = queue.PriorityQueue()
        queue_in = queue.Queue()
        threads = []
        for _ in range(threads_max):
            thread = ThreadBuild(self, queue_out, queue_in)
            threads.append(thread)
            thread.start()

        active = set()
        network = self.copy()
        while network:
            for name in (name for name, degree in network.in_degree_iter()
                         if degree == 0 and name not in active):
                queue_out.put((-network.node[name]['SuccessorsLen'], name))
                active.add(name)

            name, outcome, log = queue_in.get()

            cprint('\nBuild log: {0:s}'.format(name), 'white', attrs=['underline'])
            print(log, end='')
            if outcome:
                cprint('Build finished: {0:s}\n'.format(name), 'green')
            else:
                cprint('Build failed: {0:s}\n'.format(name), 'red')
                self.failed |= set((name,)) | self.node[name]['Successors']
                network.remove_nodes_from(self.node[name]['Successors'])

            network.remove_node(name)
            active.remove(name)
            queue_in.task_done()

        for thread in threads:
            thread.stop()

        cprint('Builds finished:', 'magenta')
        cprint('{0:s}'.format('\n'.join(sorted(self.node.keys() - self.failed))), 'green')
        if self.failed:
            cprint('Builds failed:', 'magenta')
            cprint('{0:s}'.format('\n'.join(sorted(self.failed))), 'red')


def main():
    ''' Main '''
    cprint('\nParsing Dockerfiles', 'magenta')
    network = Network(IMAGES)
    network.prune_disabled(IMAGES, ARGS.images)
    network.attr_successors()
    if ARGS.images:
        network.remove_nodes_from_except(ARGS.images, ARGS.no_successors)

    cprint('\nBuilding images', 'magenta')
    network.build(META['Limits']['Threads'])

    if not ARGS.images:
        cprint('\nCleaning up dangling images', 'magenta')
        try:
            response = request(get, '/images/json',
                               params={'filters': json.dumps({'dangling': ['true']})})
        except RuntimeError as error:
            cprint('list dangling: {0:s}'.format(str(error)), 'red')
            sys.exit(1)

        for image in response.json():
            try:
                response = request(delete, '/images/{0:s}'.format(image['Id']))
            except RuntimeError as error:
                cprint('delete: {0:s}'.format(str(error)), 'red')
                continue

            for dictionary in response.json():
                print(dictionary['Deleted'])

if __name__ == '__main__':
    ARGS = args_parse()
    main()
