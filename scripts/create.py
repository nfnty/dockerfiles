#!/usr/bin/python3
''' Create container from JSON config '''

import argparse
import json
import os.path
import sys
import uuid

from utils import unixconn


SESSION = unixconn.session()
SOCKET = '/run/docker.sock'
TIMEOUT_CONNECT = 31
TIMEOUT_READ = 181
TIMEOUT = (TIMEOUT_CONNECT, TIMEOUT_READ)


def args_parse(arguments=None):
    ''' Parse arguments '''
    par0 = argparse.ArgumentParser(description='Run container')

    # Optional
    par0.add_argument('--name', metavar='NAME', help='Name')
    par0.add_argument('--uuid', action='store_true', help='Append uuid to name')
    par0.add_argument('--entrypoint', metavar='ENTRYPOINT', help='Override ENTRYPOINT of image')

    # Positional
    par0.add_argument('config', metavar='CONFIG', help='JSON config file')
    par0.add_argument('arguments', metavar='ARGUMENTS', nargs=argparse.REMAINDER,
                      help='Arguments to pass to container')

    args0 = par0.parse_args(arguments)
    return args0


def config_devices(devices):
    ''' Convert config Devices paths into real '''
    if devices is None:
        return

    for device in devices:
        device['PathOnHost'] = os.path.realpath(device['PathOnHost'])

        if not device['PathInContainer']:
            device['PathInContainer'] = device['PathOnHost']


def config_init(config):
    ''' Initialize config '''
    if 'Image' not in config:
        print('Image not in config', file=sys.stderr)
        sys.exit(1)

    if ARGS.arguments:
        config['Cmd'] = ARGS.arguments
    if ARGS.entrypoint:
        config['Entrypoint'] = ARGS.entrypoint

    host_config = config.get('HostConfig')
    if host_config:
        config_devices(host_config.get('Devices'))


def name_format():
    ''' Format name '''
    if ARGS.name:
        if ARGS.uuid:
            return '{0:s}-{1:s}'.format(ARGS.name, uuid.uuid4().hex)
        else:
            return ARGS.name
    else:
        return uuid.uuid4().hex


def image_exists(tag):
    ''' Does image exist? '''
    response = SESSION.get(
        url=unixconn.url_format(SOCKET, '/images/{0:s}/json'.format(tag)),
        timeout=TIMEOUT,
    )

    if response.status_code == 200:
        return True
    elif response.status_code == 404:
        return False
    else:
        raise RuntimeError('{0:s}'.format(json.dumps(
            dict(**unixconn.error(response), **{'tag': tag}))))


def container_remove(name):
    ''' Remove container '''
    response = SESSION.delete(
        url=unixconn.url_format(SOCKET, '/containers/{0:s}'.format(name)),
        timeout=TIMEOUT,
    )

    if response.status_code not in (204, 404):
        raise RuntimeError('{0:s}'.format(json.dumps(
            dict(**unixconn.error(response), **{'name': name}))))


def container_create(name, config):
    ''' Create container '''
    response = SESSION.post(
        url=unixconn.url_format(SOCKET, '/containers/create'),
        headers={'Content-Type': 'application/json'},
        params={'name': name},
        data=json.dumps(config),
        timeout=TIMEOUT,
    )

    if response.status_code != 201:
        raise RuntimeError('{0:s}'.format(json.dumps(
            dict(**unixconn.error(response), **{'name': name, 'config': config}))))

    return json.loads(response.text)


def main():
    ''' Main '''
    with open(ARGS.config) as filedesc:
        config = json.load(filedesc)
    config_init(config)

    if not image_exists(config['Image']):
        print('Image does not exist: {0:s}'.format(config['Image']), file=sys.stderr)
        sys.exit(1)

    name = name_format()
    container_remove(name)
    print(json.dumps({**container_create(name, config), 'Name': name}))


if __name__ == '__main__':
    ARGS = args_parse()
    main()
