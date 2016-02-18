#!/usr/bin/python3 -u
''' Orchestrate multiple processes '''

import argparse
from collections import OrderedDict
import os
import shlex
import signal
import subprocess
import sys
import time


def args_parse():
    ''' Parse arguments '''
    parser = argparse.ArgumentParser(description='Orchestrate multiple processes')

    # Options
    parser.add_argument(
        '--start', metavar='TIME', type=float, default=60,
        help='Process startup leeway time, in seconds, default=60')
    parser.add_argument(
        '--wait', metavar='TIME', type=float, default=120,
        help='Time to wait for process termination before killing, in seconds, default=120')
    parser.add_argument(
        '--cycle', metavar='TIME', type=float, default=0.01,
        help='Time to sleep between termination cycles, in seconds, default=0.01')
    parser.add_argument(
        '--retries', metavar='TIMES', type=int, default=3,
        help='Times to restart process before failure, default=3')

    # Positional
    parser.add_argument(
        'commands', metavar='COMMANDS', nargs=argparse.REMAINDER, help='Commands')

    args = parser.parse_args()

    if not args.commands:
        print('No commands specified', file=sys.stderr)
        sys.exit(2)
    if args.commands[0] == '--':
        del args.commands[0]

    return args


def status_print(base, pid, process, items):
    ''' Print status '''
    message = '{0:s}: {1:d}'.format(base, pid)
    if process:
        message += ': Args: {0:s}'.format(str(process.args))
    if items:
        message += ', ' if process else ': '
        message += ', '.join(('{0:s}: {1:s}'.format(key, str(value)) for key, value in items))
    print(message, file=sys.stderr)


def status_decode(status):
    ''' Decode status '''
    if os.WIFSIGNALED(status):
        return True, 'Signaled', \
            (('Signal', os.WTERMSIG(status)), ('Coredump', os.WCOREDUMP(status)))
    elif os.WIFEXITED(status):
        return True, 'Exited', (('Status', os.WEXITSTATUS(status)),)
    elif os.WIFCONTINUED(status):
        return False, 'Continued', None
    elif os.WIFSTOPPED(status):
        return False, 'Stopped', (('Signal', os.WSTOPSIG(status)),)
    else:
        raise RuntimeError('Status unknown')


def start(args):
    ''' Start process '''
    try:
        process = subprocess.Popen(args)
    except Exception as error:  # pylint: disable=broad-except
        print('Start failed: {0:s}: Args: {1:s}'.format(str(error), str(args)))
        return None
    value = {'Process': process, 'Retries': 0, 'Start': time.time()}
    # pylint: disable=no-member
    print('Started: {0:d}: Args: {1:s}'.format(process.pid, str(process.args)),
          file=sys.stderr)
    # pylint: enable=no-member
    return value


def terminate(processes, gracefully):
    ''' Terminate processes '''
    print('Terminating processes', file=sys.stderr)
    for value in processes.values():
        value['Process'].terminate()

    time_start = time.time()
    killed = False
    while processes:
        pid, status = os.waitpid(-1, os.WNOHANG)

        if pid:
            process = processes[pid]['Process'] if pid in processes else None

            try:
                action, base, items = status_decode(status)
            except RuntimeError as error:
                action, base, items = True, str(error), (('Status', status),)
            status_print(base, pid, process, items)

            if process is not None and action:
                del processes[pid]
            continue

        if not killed and time.time() >= (time_start + ARGS.wait):
            killed = True
            print('Wait limit reached: Killing remaining processes', file=sys.stderr)
            for value in processes.values():
                process = value['Process']
                process.kill()
            continue

        time.sleep(ARGS.cycle)

    if killed:
        sys.exit(2)

    if gracefully:
        sys.exit(0)
    else:
        sys.exit(1)


class Signal(Exception):
    ''' Signal exception '''
    pass


def main():  # pylint: disable=too-many-branches,too-many-statements
    ''' Main '''
    signals = []

    def signal_handler(signum, frame):
        ''' Signal handler '''
        nonlocal signals
        signals.append(signum)
        if frame.f_code.co_name == 'main' \
                and 'pid' in frame.f_locals and frame.f_locals['pid'] is None:
            raise Signal

    # pylint: disable=no-member
    for sig in set(signal.Signals) - {signal.SIGCHLD, signal.SIGKILL, signal.SIGSTOP}:
        signal.signal(sig, signal_handler)
    # pylint: enable=no-member

    processes = OrderedDict()
    for command in ARGS.commands:
        value = start(shlex.split(command))
        if value is None:
            terminate(processes, False)
        processes[value['Process'].pid] = value

    while True:
        while signals:
            sig = signals.pop(0)
            if sig in (signal.SIGTERM, signal.SIGINT):
                terminate(processes, True)
            else:
                for _, value in processes.items():
                    value['Process'].send_signal(sig)

        try:
            pid = None
            pid, status = os.waitpid(-1, 0)
        except Signal:
            pid = -1
            continue

        process = processes[pid]['Process'] if pid in processes else None

        try:
            action, base, items = status_decode(status)
        except RuntimeError as error:
            status_print(str(error), pid, process, (('Status', status),))
            terminate(processes, False)
        status_print(base, pid, process, items)

        if process is None or not action:
            continue

        if time.time() >= (processes[pid]['Start'] + ARGS.start):
            print('Retries reset', file=sys.stderr)
            processes[pid]['Retries'] = 0

        if processes[pid]['Retries'] >= ARGS.retries:
            print('Maximum retries exceeded', file=sys.stderr)
            del processes[pid]
            terminate(processes, False)

        value = start(processes[pid]['Process'].args)
        if value is None:
            terminate(processes, False)
        processes[value['Process'].pid] = value
        processes[value['Process'].pid]['Retries'] = processes[pid]['Retries'] + 1
        del processes[pid]


if __name__ == '__main__':
    ARGS = args_parse()
    main()
