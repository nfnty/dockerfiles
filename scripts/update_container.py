#!/usr/bin/python3
''' Update container '''

import os
import sys
import subprocess
import argparse
import docker
import requests

SCRIPTDIR = os.path.dirname(os.path.realpath(__file__))
CLIENT = docker.Client(base_url='unix://var/run/docker.sock', version='auto')

class Container:
    ''' Container class '''
    name = None
    exts = None

    def exists(self):
        ''' Check if exists '''
        for ext in self.exts:
            name = self.name + self.exts[ext]['name']

            try:
                CLIENT.inspect_container(name)
            except (requests.exceptions.HTTPError, docker.errors.APIError):
                print(name + ' does not exist')
                continue

            self.exts[ext]['exists'] = True

    def create(self):
        ''' Create '''
        name = self.name

        try:
            subprocess.check_call([
                os.path.join(
                    os.path.dirname(SCRIPTDIR),
                    'containers', name, 'scripts/create.sh'
                )
            ])
        except subprocess.CalledProcessError:
            print('Failed to create ' + name)
            return False

        return True

    def remove(self, ext):
        ''' Remove '''
        name = self.name + self.exts[ext]['name']

        try:
            CLIENT.remove_container(name)
        except (requests.exceptions.HTTPError, docker.errors.APIError) as error:
            print('Failed to remove ' + name)
            print(str(error))
            return False

        return True

    def rename(self, ext_from, ext_to):
        ''' Rename '''
        name_from = self.name + self.exts[ext_from]['name']
        name_to = self.name + self.exts[ext_to]['name']

        try:
            CLIENT.rename(name_from, name_to)
        except (requests.exceptions.HTTPError, docker.errors.APIError) as error:
            print(
                'Failed to rename ' +
                name_from +
                ' to ' +
                name_to
            )
            print(str(error))
            return False

        self.exts[ext_from]['exists'] = False
        self.exts[ext_to]['exists'] = True
        return True

    def running(self):
        ''' Check if running '''
        name = self.name

        try:
            subprocess.check_call(
                ['/usr/bin/systemctl', 'status', 'docker_' + name],
                stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT
            )
        except subprocess.CalledProcessError:
            print(name + ' is not running')
            return False

        return True

    def start(self):
        ''' Start '''
        name = self.name

        try:
            subprocess.check_call(
                ['/usr/bin/systemctl', 'start', 'docker_' + name],
                stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT
            )
        except subprocess.CalledProcessError:
            print('Failed to start ' + name)
            return False

        return True

    def stop(self):
        ''' Stop '''
        name = self.name

        try:
            subprocess.check_call(
                ['/usr/bin/systemctl', 'stop', 'docker_' + name],
                stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT
            )
        except subprocess.CalledProcessError:
            print('Failed to stop ' + name)
            return False

        return True

def args_parse():
    ''' Parse arguments '''
    parser = argparse.ArgumentParser(
        description='Docker container updater'
    )

    # Optional
    parser.add_argument(
        '--off', action='store_true',
        help='Keep container turned off after update'
    )

    # Positional
    parser.add_argument(
        'name', metavar='NAME', action='store',
        help='Name of container',
    )

    return parser.parse_args()

def main():
    ''' Main '''
    # Parse arguments
    args = args_parse()

    container = Container()
    container.name = args.name
    container.exts = {
        '0': {
            'name': '',
            'exists': False
        },
        '1': {
            'name': '_old1',
            'exists': False
        },
        '2': {
            'name': '_old2',
            'exists': False
        },
        '3': {
            'name': '_old3',
            'exists': False
        }
    }
    container.exists()

    print('Renaming 2 to 3')
    if container.exts['2']['exists']:
        if not container.rename('2', '3'):
            sys.exit(1)

    print('Renaming 1 to 2')
    if container.exts['1']['exists']:
        if not container.rename('1', '2'):
            sys.exit(1)

    print('Stopping container')
    if container.running():
        if not container.stop():
            if container.exts['2']['exists']:
                container.rename('2', '1')
            if container.exts['3']['exists']:
                container.rename('3', '2')
            sys.exit(1)

    print('Renaming 0 to 1')
    if container.exts['0']['exists']:
        if not container.rename('0', '1'):
            sys.exit(1)

    print('Creating container')
    if not container.create():
        if container.exts['1']['exists']:
            container.rename('1', '0')
        if container.exts['2']['exists']:
            container.rename('2', '1')
        if container.exts['3']['exists']:
            container.rename('3', '2')
        container.start()
        sys.exit(1)

    if not args.off:
        print('Starting container')
        if not container.start():
            sys.exit(1)

    if container.exts['3']['exists']:
        print('Removing container 3')
        if not container.remove('3'):
            sys.exit(1)

if __name__ == '__main__':
    main()
