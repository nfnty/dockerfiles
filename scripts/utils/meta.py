''' Meta '''

import subprocess
import sys
import os
from typing import List

from termcolor import cprint


__all__ = ['PATH_REPO', 'failed']


def path_repo() -> str:
    ''' Repository path '''
    return run_pipe([  # type: ignore
        '/usr/bin/git', '-C', os.path.dirname(os.path.realpath(__file__)),
        'rev-parse', '--show-toplevel'
    ]).stdout.decode('UTF-8').rstrip('\n')


def failed(string: str) -> None:
    ''' Print string and exit '''
    cprint(string, 'red', file=sys.stderr)
    sys.exit(1)


def run(command: List[str]) -> str:
    ''' Run command '''
    try:
        process = subprocess.run(
            command, check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as error:
        # pylint: disable=no-member
        raise RuntimeError('{0:s}\n{1:s}'.format(str(error), error.stdout.decode('UTF-8')))
        # pylint: enable=no-member
    return process.stdout.decode('UTF-8')  # type: ignore


def run_pipe(command: List[str]) -> subprocess.CompletedProcess:
    ''' Run command, return CompletedProcess '''
    try:
        process = subprocess.run(
            command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as error:
        # pylint: disable=no-member
        raise RuntimeError('{0:s}\n{1:s}\n{2:s}'.format(
            str(error), error.stdout.decode('UTF-8'), error.stderr.decode('UTF-8')))
        # pylint: enable=no-member
    return process


PATH_REPO = path_repo()
