#!/usr/bin/python3
''' Stop systemd docker scope '''

import os
import subprocess
import sys


def main():
    ''' Main '''
    name = os.environ['CNAME']

    try:
        process = subprocess.run([
            '/usr/bin/docker', 'inspect', '--format={{ .Id }}', name
        ], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        identity = process.stdout.decode('UTF-8').rstrip('\n')

        subprocess.run(['/usr/bin/systemctl', 'stop', 'docker-{0:s}.scope'.format(identity)],
                       check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as error:
        print('{0:s} {1:s} {2:s}'.format(
            str(error), str(error.stdout), str(error.stderr)), file=sys.stderr)

if __name__ == '__main__':
    main()
