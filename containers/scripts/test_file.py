#!/usr/bin/python3
''' Test file properties and permissions '''

import sys
import os
import subprocess

MAXUGID = (2**32)-2

TESTOPTS = {
    'd': 'directory',
    'f': 'regular file',
    'b': 'block special',
    'c': 'character special',
    'L': 'symbolic link',
    'p': 'named pipe',
    'S': 'socket',

    'r': 'read',
    'w': 'write',
    'x': 'execute',

    'U': 'euid',
    'G': 'egid',

    'u': 'setuid',
    'g': 'setgid',

    'k': 'sticky',
}

REMAP = {
    'U': 'O'
}

ALWAYSTEST = [
    'r',
    'w',
    'x',
    'U',
    'G',
    'u',
    'g',
    'k'
]

def main():
    ''' Main function '''

    opts = sys.argv[1]
    ugid = sys.argv[2]
    testpath = sys.argv[3]

    if not ugid.isdigit and not 0 <= int(ugid) <= MAXUGID:
        print('Invalid UGID: ' + ugid)

    nottest = ALWAYSTEST
    for opt in opts:
        if not opt in TESTOPTS:
            print('Incorrect test option: ' + opt)
            print('Test options: ' + opts)
            sys.exit(1)

        if opt in nottest:
            nottest.remove(opt)

        if opt in REMAP:
            ropt = REMAP[opt]
        else:
            ropt = opt

        try:
            subprocess.check_call([
                'sudo',
                '--user=#' + ugid,
                '--group=#' + ugid,
                'test', '-' + ropt, testpath
            ])
        except subprocess.CalledProcessError:
            print('File test failed!')
            print('UGID: ' + ugid)
            print('Path: ' + testpath)
            print('Test: ' + opt + ' (' + TESTOPTS[opt]  + ')')
            sys.exit(1)

    for opt in nottest:
        if opt in REMAP:
            ropt = REMAP[opt]
        else:
            ropt = opt

        try:
            subprocess.check_call([
                'sudo',
                '--user=#' + ugid,
                '--group=#' + ugid,
                'test', '-' + ropt, testpath
            ])
        except subprocess.CalledProcessError:
            continue

        print('File NOT test failed!')
        print('UGID: ' + ugid)
        print('Path: ' + testpath)
        print('Test: ' + opt + ' (' + TESTOPTS[opt]  + ')')
        sys.exit(1)

    print('File test passed: ' + testpath)


if __name__ == '__main__':
    main()
