#!/usr/bin/python3
''' Update container '''

import os
import sys
import subprocess
import argparse
import docker
import requests

SCRIPTDIR = os.path.dirname(os.path.realpath(__file__))
CLIENT = docker.Client(base_url='unix://run/docker.sock', version='auto')

def error_print_exit(error):
    ''' Print error and exit '''
    print(error)
    sys.exit(1)
def print_separator():
    ''' Prints a separator for readability '''
    print('\n##################################################\n')

class Container:
    ''' Container class '''
    def __init__(self, name):
        self.name = name
        self.exists = False
    def doesexist(self):
        ''' Exists? '''
        try:
            CLIENT.inspect_container(self.name)
            self.exists = True
        except (requests.exceptions.HTTPError, docker.errors.APIError):
            self.exists = False
    def create(self, basename):
        ''' Create '''
        try:
            subprocess.check_call([
                os.path.join(
                    os.path.abspath(os.path.join(SCRIPTDIR, '../..')),
                    'containers', basename, 'scripts/create.sh'
                ),
                self.name
            ])
            self.exists = True
            print('Created ' + self.name)
        except subprocess.CalledProcessError as error:
            error_print_exit(error)
    def remove(self):
        ''' Remove '''
        try:
            CLIENT.remove_container(self.name)
            print('Removed ' + self.name)
            self.exists = False
        except (requests.exceptions.HTTPError, docker.errors.APIError) as error:
            print('Failed to remove ' + self.name)
            error_print_exit(error)
    def rename(self, name_to):
        ''' Rename '''
        try:
            CLIENT.rename(self.name, name_to)
            print('Renamed ' + self.name + ' to ' + name_to)
            self.name = name_to
        except (requests.exceptions.HTTPError, docker.errors.APIError) as error:
            print('Failed to rename ' + self.name + ' to ' + name_to)
            error_print_exit(error)
    def running(self):
        ''' Running? '''
        try:
            return CLIENT.inspect_container(self.name)['State']['Running']
        except (requests.exceptions.HTTPError, docker.errors.APIError) as error:
            print('Failed to gauge running state of ' + self.name)
            error_print_exit(error)
    def stop(self):
        ''' Stop '''
        try:
            subprocess.check_call(
                ['/usr/bin/systemctl', 'stop', 'docker_' + self.name],
                stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT
            )
            print('Stopped ' + self.name)
        except subprocess.CalledProcessError as error:
            print('Failed to stop ' + self.name)
            error_print_exit(error)
    def start(self):
        ''' Start '''
        try:
            subprocess.check_call(
                ['/usr/bin/systemctl', 'start', 'docker_' + self.name],
                stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT
            )
            print('Started ' + self.name)
        except subprocess.CalledProcessError as error:
            print('Failed to start ' + self.name)
            error_print_exit(error)

def rename(containers, name, prefix):
    ''' Rename containers '''
    for index, container in reversed(list(enumerate(containers))):
        if index == 0:
            container.rename(name)
        else:
            container.rename(prefix + str(index) + '_' + name)

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
    parser.add_argument(
        '--nostop', action='store_true',
        help='Do not stop container'
    )
    parser.add_argument(
        '--backups', default=1,
        help='Number of backups to keep; default = \'1\''
    )
    parser.add_argument(
        '--prefix', default='bak',
        help='Name prefix to use; default = \'bak\''
    )
    parser.add_argument(
        '--name', action='store',
        help='Name of container'
    )

    # Positional
    parser.add_argument(
        'basename', metavar='BASENAME', action='store',
        help='Base name of container',
    )

    return parser.parse_args()

def main():
    ''' Main '''
    print_separator()

    # Parse arguments
    args = args_parse()
    if not args.name:
        args.name = args.basename

    # Initialize containers
    containers = []
    for index in range(int(args.backups)+1):
        if index == 0:
            container = Container(args.name)
        else:
            container = Container(args.prefix + str(index) + '_' + args.name)

        container.doesexist()

        if container.exists:
            containers.append(container)
        else:
            break

    # Create container
    containers[0].rename('tmp_' + args.name)
    containers.insert(0, Container(args.name))
    containers[0].create(args.basename)
    containers[0].rename(args.prefix + '0' + '_' + args.name)
    containers[1].rename(args.name)

    # Stop container
    if not args.nostop and len(containers) > 1 and containers[1].running():
        containers[1].stop()

    # Rename containers
    rename(containers, args.name, args.prefix)

    # Start container
    if not args.off:
        containers[0].start()

    # Remove abundant backup
    if containers[-1].name == args.prefix + str(int(args.backups)+1) + '_' + args.name:
        containers[-1].remove()
        del containers[-1]

if __name__ == '__main__':
    main()
