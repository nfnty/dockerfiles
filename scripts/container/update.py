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

def error_print_exit(error):
    ''' Print error and exit '''
    print(error)
    sys.exit(1)
def print_separator():
    ''' Prints a separator for redability '''
    print('\n##################################################\n')

class Container:
    ''' Container class '''
    def __init__(self, name):
        self.name = name

        try:
            CLIENT.inspect_container(self.name)
            self.exists = True
        except (requests.exceptions.HTTPError, docker.errors.APIError):
            self.exists = False
    def create(self):
        ''' Create '''
        try:
            subprocess.check_call([
                os.path.join(
                    os.path.abspath(os.path.join(SCRIPTDIR, '../..')),
                    'containers', self.name, 'scripts/create.sh'
                )
            ])
            self.exists = True
            print('Created ' + self.name)
            return True
        except subprocess.CalledProcessError as error:
            print('Failed to create ' + self.name)
            print(str(error))
            return False
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
            CLIENT.stop(self.name)
            print('Stopped ' + self.name)
            return True
        except (requests.exceptions.HTTPError, docker.errors.APIError) as error:
            print('Failed to stop ' + self.name)
            print(str(error))
            return False
    def restart(self):
        ''' Restart '''
        try:
            subprocess.check_call(
                ['/usr/bin/systemctl', 'restart', 'docker_' + self.name],
                stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT
            )
            print('Restarted ' + self.name)
            return True
        except subprocess.CalledProcessError as error:
            print('Failed to restart ' + self.name)
            print(str(error))
            return False

def rename(containers, name, prefix):
    ''' Rename containers '''
    for index, container in reversed(list(enumerate(containers))):
        if container.exists:
            container.rename(prefix + str(index+1) + '_' + name)
def rename_revert(containers, name, prefix):
    ''' Revert renaming '''
    for index, container in enumerate(containers):
        if container.exists:
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
        '--backups', default=1,
        help='Number of backups to keep; default = \'1\''
    )
    parser.add_argument(
        '--prefix', default='bak',
        help='Name prefix to use; default = \'bak\''
    )

    # Positional
    parser.add_argument(
        'name', metavar='NAME', action='store',
        help='Name of container',
    )

    return parser.parse_args()

def main():
    ''' Main '''
    print_separator()

    # Parse arguments
    args = args_parse()

    # Initialize containers
    containers = [Container(args.name)]
    for num in range(1, args.backups+1):
        containers.append(Container(args.prefix + str(num) + '_' + args.name))

    # Rename containers
    rename(containers, args.name, args.prefix)

    # Create container
    containers.insert(0, Container(args.name))
    if not containers[0].create():
        containers = containers[1:]
        rename_revert(containers, args.name, args.prefix)
        sys.exit(1)

    # Stop container
    if containers[1].running():
        if not containers[1].stop():
            rename_revert(containers, args.name, args.prefix)
            sys.exit(1)

    # Start container
    if not args.off:
        if not containers[0].restart():
            containers[0].remove()
            containers = containers[1:]
            rename_revert(containers, args.name, args.prefix)
            sys.exit(1)

    # Remove abundant backup
    if containers[-1].exists:
        containers[-1].remove()

if __name__ == '__main__':
    main()
