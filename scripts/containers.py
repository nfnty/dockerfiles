#!/usr/bin/python3
''' Orchestrate containers '''

import argparse
from copy import deepcopy
import json
import queue
import sys
import threading

from termcolor import cprint, colored

from utils.network import DiGraph
from utils import string
from utils.api import decode_attach
from utils.container import CONTAINERS, META, Container, \
    get_existing, backups_rename, backups_cleanup
from utils.meta import failed, dict_merge_copy


def args_parse(arguments=None):
    ''' Parse arguments '''
    class ActionSet(argparse.Action):  # pylint: disable=too-few-public-methods
        ''' argparse Action parse into set '''
        def __init__(self, option_strings, dest, **kwargs):
            super(ActionSet, self).__init__(option_strings, dest, **kwargs)

        def __call__(self, parser, namespace, values, option_string=None):
            setattr(namespace, self.dest, set(values))

    par0 = argparse.ArgumentParser(description='Orchestrate containers')
    par0.add_argument('mode', metavar='MODE', choices=('manage', 'run'), help='Mode to run')
    par0.add_argument('arguments', metavar='ARGUMENTS', nargs=argparse.REMAINDER,
                      help='Arguments to pass to mode')
    args0 = par0.parse_args(arguments)

    if args0.mode == 'manage':
        par1 = argparse.ArgumentParser(description='Manage containers')

        # Main arguments
        mode = par1.add_mutually_exclusive_group(required=True)
        mode.add_argument('--create', action='store_true', help='Create')
        mode.add_argument('--modify', action='store_true', help='Modify')
        mode.add_argument('--setup', action='store_true', help='Setup')
        mode.add_argument('--update', action='store_true', help='Update')

        # Optional
        par1.add_argument('--no-successors', action='store_true', help='No successors')
        par1.add_argument('--orphans', action='store_true', help='Orphans only')
        par1.add_argument('--perms', action='store_true', help='Enforce permissions')

        # Positional
        par1.add_argument('containers', metavar='CONTAINER', action=ActionSet, nargs='*',
                          help='Name of container')

    elif args0.mode == 'run':
        par1 = argparse.ArgumentParser(description='Run container')

        # Main arguments
        mode = par1.add_mutually_exclusive_group()
        mode.add_argument('--modify', action='store_true', help='Modify')

        # Optional
        par1.add_argument('--create', action='store_true', help='Only create')
        par1.add_argument('--name', metavar='NAME', help='Name')
        par1.add_argument('--perms', action='store_true', help='Enforce permissions')
        par1.add_argument('--rm', action='store_true', help='Remove on exit')

        # Positional
        par1.add_argument('container', metavar='CONTAINER', help='Container')
        par1.add_argument('arguments', metavar='ARGUMENTS', nargs=argparse.REMAINDER,
                          help='Arguments to pass to container')

    args1 = par1.parse_args(args0.arguments)
    args1.mode = args0.mode
    return args1


class ThreadBuild(threading.Thread):
    ''' Container builder '''
    def __init__(self, network, queue_in, queue_out):
        threading.Thread.__init__(self, daemon=True)
        self._stop = threading.Event()
        self.network = network
        self.queue_in = queue_in
        self.queue_out = queue_out

        self.mode = None
        self.name = None

    def _return(self, outcome, log):
        self.queue_out.put((self.mode, self.name, outcome, log))
        self.queue_in.task_done()

    def stop(self):
        ''' Stop thread '''
        self._stop.set()

    def stopped(self):
        ''' Is thread stopped '''
        return self._stop.is_set()

    def _mode_create(self, container):
        ''' Create container '''
        container.name = string.add_uuid(container.name)
        try:
            container.create()
        except RuntimeError as error:
            self._return(False, 'Create container: {0:s}\n'.format(str(error)))
            return
        self._return(True, 'Created: {0:s}\n'.format(container.name))

    def _mode_stop(self, backups):
        ''' Stop backups[0] '''
        if len(backups) >= 1 and backups[0].name == self.name:
            try:
                backups[0].stop_systemd()
            except RuntimeError as error:
                self._return(False, 'Stop Backups[0]: {0:s}\n'.format(str(error)))
                return
            self._return(True, 'Stopped: {0:s}\n'.format(backups[0].name))
            return
        self._return(True, 'No backup to stop\n')

    def _mode_rename(self, container, backups):
        ''' Rename backups and container'''
        log = 'Renaming\n'
        try:
            renamed = backups_rename(self.name, backups)
        except RuntimeError as error:
            log += '{0:s}\n'.format(str(error))
            self._return(False, log)
            return
        log += '{0:s}\n'.format(
            '\n'.join(('{0:s} -> {1:s}'.format(old, new) for old, new in renamed)))

        old = container.name
        try:
            container.rename(string.rm_uuid(container.name))
        except RuntimeError as error:
            log += '{0:s}\n'.format(str(error))
            self._return(False, log)
            return
        log += '{0:s} -> {1:s}\n'.format(old, container.name)
        self._return(True, log)

    def _mode_start(self, container):
        ''' Start container '''
        try:
            container.start_systemd()
        except RuntimeError as error:
            self._return(False, 'Start container: {0:s}\n'.format(str(error)))
            return
        self._return(True, 'Started container\n')

    def _mode_cleanup(self, backups):
        ''' Cleanup backups '''
        try:
            removed = backups_cleanup(self.name, backups)
        except RuntimeError as error:
            self._return(False, 'Cleanup: {0:s}\n'.format(str(error)))
            return
        self._return(True, '{0:s}\nCleanup done\n'.format(
            '\n'.join(('Removed: ' + name for name in removed))))

    def _mode_setup(self, container):
        ''' Setup container '''
        log = 'Starting setup\n'

        container.name = string.add_uuid(container.name)
        try:
            container.create_setup()
            log += 'Created: {0:s}\n'.format(container.name)

            container.start()
            log += 'Started\n'

            response = container.attach()
            log += 'Attached\n'
            for stream_type, output in decode_attach(response.raw):
                if stream_type == 'stdout':
                    log += output
                elif stream_type == 'stderr':
                    log += colored(output, 'yellow')

            container.remove()
            log += 'Removed\n'
        except RuntimeError as error:
            log += 'Error: {1:s}\n'.format(str(error))
            self._return(False, log)
            return

        log += 'Setup done\n'
        self._return(True, log)

    def _mode_permissions(self, container):
        ''' Enforce permissions '''
        log = 'Enforcing permissions\n'
        try:
            log += container.permissions()
        except RuntimeError as error:
            log += '{0:s}\n'.format(str(error))
            self._return(False, log)
            return
        log += 'Enforced permissions\n'
        self._return(True, log)

    def run(self):
        while True:
            try:
                _, (self.mode, self.name) = self.queue_in.get(timeout=0.1)
            except queue.Empty:
                if self.stopped():
                    return
                continue

            container = self.network.node[self.name]['Object']
            backups = self.network.node[self.name]['Backups']

            if self.mode == 'create':
                self._mode_create(container)
            elif self.mode == 'stop':
                self._mode_stop(backups)
            elif self.mode == 'rename':
                self._mode_rename(container, backups)
            elif self.mode == 'start':
                self._mode_start(container)
            elif self.mode == 'cleanup':
                self._mode_cleanup(backups)
            elif self.mode == 'setup':
                self._mode_setup(container)
            elif self.mode == 'permissions':
                self._mode_permissions(container)
            else:
                raise RuntimeError('Incorrect mode: {0:s}'.format(self.mode))


class Network(DiGraph):
    ''' Network of containers '''
    def __init__(self, config_containers):
        super(Network, self).__init__()

        for container, config_container in config_containers.items():
            for name, config_name in config_container['Names'].items():
                config = dict_merge_copy(config_container, config_name)
                self.add_node(name, {'Object': Container(container, name, config)})
                if 'Depends' in config:
                    for dependency in config['Depends']:
                        self.add_edge(dependency, name)

    def attr_backups(self):
        ''' Add Backups attributes to nodes '''
        existing = get_existing()
        for node, value in self.node.items():
            value['Backups'] = []
            regex = string.re_backup(node)

            backups = []
            for name, identity in existing:
                if name == node:
                    value['Backups'].append(
                        Container(value['Object'].basename, name, identity=identity))
                elif regex.match(name):
                    backups.append(
                        Container(value['Object'].basename, name, identity=identity))

            self.node[node]['Backups'] += sorted(
                backups, key=lambda container, node=node: string.backup_num(node, container.name))

    def orphans(self):
        ''' container is an orphan if using an unnamed image '''
        return set(
            node
            for node, value in self.node.items()
            if len(value['Backups']) >= 1 and
            value['Backups'][0].name == value['Object'].name and
            value['Backups'][0].orphan()
        )

    def _nodes(self):
        ''' nodes not failed '''
        return self.node.keys() - self.failed

    def _copy(self):
        ''' network copy without failed '''
        network = self.copy()
        network.remove_nodes_from(self.failed)
        return network

    def _build_all(self, mode, queue_out, queue_in):
        ''' Build all at once'''
        names = self._nodes()
        for name in names:
            queue_out.put((0, (mode, name)))
        while names:
            _, name, outcome, log = queue_in.get()
            self.node[name]['Log'] += log
            if not outcome:
                self.failed |= set((name,)) | self.successors_all(name)
            names.remove(name)
            queue_in.task_done()

    # pylint: disable=too-many-branches,too-many-locals,too-many-statements
    def _build_restart(self, queue_out, queue_in):
        ''' Build restart '''
        network = self._copy()
        network_stop = network.copy()
        network_start = network.copy()
        names_rename = self._nodes()
        names_permissions = names_rename.copy()

        for name, degree in network_stop.out_degree_iter():
            if degree == 0:
                queue_out.put((-len(network.connected(name)), ('stop', name)))

        while network_start:  # pylint: disable=too-many-nested-blocks
            mode, name, outcome, log = queue_in.get()
            self.node[name]['Log'] += log

            if not outcome:
                fail = set((name,)) | network.successors_all(name)
                self.failed |= fail
                for obj in (network, network_stop, network_start):
                    obj.remove_nodes_from(fail)
                for obj in (names_rename, names_permissions):
                    obj -= fail
                queue_in.task_done()
                continue

            connected = network.connected(name)
            length = len(connected)

            if mode == 'stop':
                if network_stop.in_degree(name) == 0:
                    network_stop.remove_node(name)
                    if not connected & network_stop.node.keys():
                        for node in connected:
                            queue_out.put((-length, ('rename', node)))
                else:
                    for node in network_stop.predecessors_iter(name):
                        if network_stop.out_degree(node) == 1:
                            queue_out.put((-length, ('stop', node)))
                    network_stop.remove_node(name)

            elif mode == 'rename':
                names_rename.remove(name)
                if not connected & names_rename:
                    if ARGS.perms:
                        for node in connected:
                            queue_out.put((-length, ('permissions', node)))
                    else:
                        for node in connected:
                            if network_start.in_degree(node) == 0:
                                queue_out.put((-length, ('start', node)))

            elif mode == 'permissions':
                names_permissions.remove(name)
                if not connected & names_permissions:
                    for node in connected:
                        if network_start.in_degree(node) == 0:
                            queue_out.put((-length, ('start', node)))

            elif mode == 'start':
                for node in network_start.successors_iter(name):
                    if network_start.in_degree(node) == 1:
                        queue_out.put((-length, ('start', node)))
                network_start.remove_node(name)

            else:
                raise RuntimeError('Incorrect mode: {0:s}'.format(mode))

            queue_in.task_done()
    # pylint: enable=too-many-branches,too-many-locals,too-many-statements

    def build(self, threads_max):
        ''' Build '''
        queue_out = queue.PriorityQueue()
        queue_in = queue.Queue()
        threads = []
        for _ in range(threads_max):
            thread = ThreadBuild(self, queue_out, queue_in)
            threads.append(thread)
            thread.start()

        for value in self.node.values():
            value['Log'] = ''

        if ARGS.setup:
            self._build_all('setup', queue_out, queue_in)
        elif ARGS.modify:
            if ARGS.perms:
                self._build_all('permissions', queue_out, queue_in)
        else:
            self._build_all('create', queue_out, queue_in)
            if ARGS.create:
                self._build_all('rename', queue_out, queue_in)
            else:
                self._build_restart(queue_out, queue_in)
            self._build_all('cleanup', queue_out, queue_in)

        for name in sorted(self.node.keys()):
            cprint('Build log: {0:s}'.format(name), 'white')
            print(self.node[name]['Log'])

        for thread in threads:
            thread.stop()

        cprint('Builds finished:', 'magenta')
        cprint('{0:s}'.format('\n'.join(sorted(self._nodes()))), 'green')
        if self.failed:
            cprint('Builds failed:', 'magenta')
            cprint('{0:s}'.format('\n'.join(sorted(self.failed))), 'red')


def config_args_validate(network):
    ''' Validate config and arguments '''
    if ARGS.containers:
        # Check if containers present in config
        missing = ARGS.containers - network.node.keys()
        if missing:
            failed('container{0:s} not in config: {1:s}'.format(
                's' if len(missing) >= 2 else '', str(missing)))

    error = ''
    for node, value in network.node.items():
        if 'Create' not in value['Object'].config:
            error += '\'Create\' missing from config: {0:s}\n'.format(node)
        if ARGS.setup:
            if 'Setup' not in value['Object'].config:
                error += '\'Setup\' missing from config: {0:s}\n'.format(node)
    if error:
        failed(error)


def main():  # pylint: disable=too-many-branches
    ''' Main '''
    if ARGS.mode == 'manage':
        network = Network(CONTAINERS)
        network.attr_backups()
        if ARGS.orphans:
            orphans = network.orphans()
            if not orphans:
                failed('Found no orphans')
            ARGS.containers |= orphans
        if ARGS.containers:
            if ARGS.no_successors:
                network.remove_nodes_from_except(ARGS.containers, True)
            else:
                network.remove_nodes_from_except(ARGS.containers, False)
        config_args_validate(network)
        network.build(META['Limits']['Threads'])

    elif ARGS.mode == 'run':
        if ARGS.container not in CONTAINERS:
            failed('Container not in config: {0:s}'.format(ARGS.container))

        container = Container(ARGS.container, ARGS.name, deepcopy(CONTAINERS[ARGS.container]),
                              path_basename=True, command=ARGS.arguments)

        if ARGS.perms:
            cprint('Enforcing permissions', 'green')
            print(container.permissions())

        if ARGS.modify:
            sys.exit(0)

        container.create()
        cprint('Container created', 'green')

        if not ARGS.create:
            container.start()
            cprint('Container started', 'green')

            for stream_type, output in decode_attach(container.attach().raw):
                if stream_type == 'stdout':
                    print(output, end='')
                elif stream_type == 'stderr':
                    cprint(output, 'yellow', end='')

        inspect = container.inspect()
        if 'State' in inspect and 'ExitCode' in inspect['State']:
            exitcode = inspect['State']['ExitCode']
        else:
            cprint('Unable to determine ExitCode', 'red')
            print(json.dumps(inspect, indent=4))
            exitcode = 255

        if ARGS.rm:
            container.remove()
            cprint('Container removed', 'green')

        sys.exit(exitcode)

if __name__ == '__main__':
    ARGS = args_parse()
    main()
