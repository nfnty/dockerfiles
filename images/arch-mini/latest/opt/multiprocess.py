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
        '--retries', metavar='TIMES', type=int, default=3,
        help='Times to retry on process failure before termination, default=3')

    # Positional
    parser.add_argument(
        'commands', metavar='COMMANDS', nargs=argparse.REMAINDER, help='Commands')

    args = parser.parse_args()

    if not args.commands:
        print('No commands specified', file=sys.stderr)
        sys.exit(1)
    if args.commands[0] == '--':
        del args.commands[0]

    return args


def print_err(base, process, items=None):
    ''' Print error '''
    message = base + ': {0:s}: pid: {1:d}, '.format(str(process.args), process.pid)
    if items:
        message += ', '.join(('{0:s}: {1:s}'.format(key, str(value)) for key, value in items))
    print(message, file=sys.stderr)


def terminate(processes):
    ''' Terminate processes '''
    print('Terminating processes', file=sys.stderr)
    for pid, values in processes.copy().items():
        process = values['Process']
        process.terminate()
        try:
            process.wait(timeout=ARGS.wait)
        except subprocess.TimeoutExpired:
            process.kill()
            base = 'Process killed'
        else:
            base = 'Process terminated'
        print_err(base, process, (('returncode', process.returncode),))
        del processes[pid]


class Signal(Exception):
    ''' Signal exception '''
    pass


def main():  # pylint: disable=too-many-branches,too-many-statements
    ''' Main '''
    signal_send = []

    def signal_handler(signum, frame):
        ''' Signal handler '''
        nonlocal signal_send
        signal_send.append(signum)
        if frame.f_code.co_name == 'main' \
                and 'pid' in frame.f_locals and frame.f_locals['pid'] is None:
            raise Signal

    # pylint: disable=no-member
    for sig in set(signal.Signals) - {signal.SIGKILL, signal.SIGSTOP, signal.SIGCHLD}:
        signal.signal(sig, signal_handler)
    # pylint: enable=no-member

    processes = OrderedDict()
    for command in ARGS.commands:
        process = subprocess.Popen(shlex.split(command))
        processes[process.pid] = {
            'Process': process, 'Signals': 0, 'Retries': 0, 'Time': time.time()}

    while True:
        while signal_send:
            sig = signal_send.pop()
            if sig in (signal.SIGTERM, signal.SIGINT):
                terminate(processes)
                sys.exit(0)
            else:
                for _, values in processes.items():
                    values['Signals'] += 1
                    values['Process'].send_signal(sig)

        try:
            pid = None
            pid, status = os.waitpid(-1, 0)
        except Signal:
            pid = 0
            continue
        process = processes[pid]['Process']

        if os.WIFSIGNALED(status):
            print_err('Process signaled', process,
                      (('signal', os.WTERMSIG(status)), ('coredump', os.WCOREDUMP(status))))
        elif os.WIFEXITED(status):
            print_err('Process exited', process, (('status', os.WEXITSTATUS(status)),))
        elif os.WIFCONTINUED(status):
            print_err('Process continued', process)
            continue
        elif os.WIFSTOPPED(status):
            print_err('Process stopped', process, (('signal', os.WSTOPSIG(status)),))
            continue
        else:
            print_err('Status unknown', process, (('status', status),))
            del processes[pid]
            terminate(processes)
            sys.exit(1)

        if (time.time() - processes[pid]['Time']) >= ARGS.start:
            processes[pid]['Retries'] = 0

        if processes[pid]['Retries'] < ARGS.retries:
            if processes[pid]['Signals']:
                processes[pid]['Signals'] -= 1
            else:
                processes[pid]['Retries'] += 1
            process = subprocess.Popen(processes[pid]['Process'].args)
            processes[process.pid] = processes[pid].copy()
            processes[process.pid]['Time'] = time.time()
            del processes[pid]
            processes[process.pid]['Process'] = process
        else:
            print('Maximum retries exceeded', file=sys.stderr)
            del processes[pid]
            terminate(processes)
            sys.exit(1)


if __name__ == '__main__':
    ARGS = args_parse()
    main()
