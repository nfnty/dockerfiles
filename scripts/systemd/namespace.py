#!/usr/bin/python3
''' Namespace setup '''

import os
import subprocess
import sys
import time


PATH_RUN = '/run/netns'
PATH_PROC = '/proc'
PATH_NETNS = 'ns/net'
INTERFACE = 'eth0'
RETRIES = 30


def container_pid(name):
    ''' Container PID '''
    for _ in range(RETRIES):
        try:
            process = subprocess.run([
                '/usr/bin/docker', 'inspect', '--format={{ .State.Pid }}', name
            ], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        except subprocess.CalledProcessError as error:
            print('ERROR: {0:s}:\n{1:s}\n{2:s}'.format(
                str(error), str(error.stdout), str(error.stderr)), file=sys.stderr)
            continue

        pid = process.stdout.decode('UTF-8').rstrip('\n')
        if pid.isdigit() and int(pid) >= 1:
            break

        time.sleep(0.1)
    else:
        print('PID is invalid: {0:s}'.format(pid), file=sys.stderr)
        return None

    return pid


def run(command, errexit=True):
    ''' Run command '''
    try:
        subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as error:
        print('{0:s} {1:s}'.format(str(error), str(error.stdout)), file=sys.stderr)
        if errexit:
            sys.exit(1)


def main():
    ''' Main '''
    name = os.environ['CNAME']
    bridge = os.environ['BRNAME']
    interface = os.environ['IFNAME']
    mac = os.environ['MACADDR']
    ipaddr = os.environ['IPADDR']
    route = os.environ['DROUTE']

    if sys.argv[1] == 'up':
        pid = container_pid(name)
        if pid is None:
            sys.exit(1)

        os.makedirs(PATH_RUN, exist_ok=True)
        os.symlink(os.path.join(PATH_PROC, pid, PATH_NETNS), os.path.join(PATH_RUN, pid))

        cmd = ['/usr/bin/ip', 'link']
        run(cmd + ['add', 've_' + interface, 'type', 'veth', 'peer', 'name', 'vp_' + interface])
        run(['/usr/bin/brctl', 'addif', bridge, 've_' + interface])
        run(cmd + ['set', 've_' + interface, 'up'])
        run(cmd + ['set', 'vp_' + interface, 'netns', pid])

        cmd = ['/usr/bin/ip', 'netns', 'exec', pid, 'ip']
        run(cmd + ['link', 'set', 'dev', 'vp_' + interface, 'name', INTERFACE])
        run(cmd + ['link', 'set', INTERFACE, 'address', mac])
        run(cmd + ['link', 'set', INTERFACE, 'up'])
        run(cmd + ['addr', 'add', ipaddr, 'dev', INTERFACE])
        run(cmd + ['route', 'add', 'default', 'via', route])

    elif sys.argv[1] == 'down':
        run(['/usr/bin/ip', 'link', 'delete', 've_' + interface], errexit=False)
        run(['/usr/bin/find', '-L', PATH_RUN, '-type', 'l', '-delete'], errexit=False)

    else:
        raise ValueError('sys.argv[1] is incorrect')


if __name__ == '__main__':
    main()
