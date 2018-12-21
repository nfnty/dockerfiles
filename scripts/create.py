#!/usr/bin/python3
''' Create container from JSON config '''

import argparse
import json
import os.path
import sys
import uuid
from typing import Any, Dict, Sequence, Tuple

from utils import unixconn


SESSION = unixconn.session()
SOCKET: str = '/run/docker.sock'
TIMEOUT: Tuple[int, int] = (31, 181)  # (Connect, Read)


def args_parse(arguments: Sequence[str] = None) -> argparse.Namespace:
    ''' Parse arguments '''
    par0 = argparse.ArgumentParser(description='Run container')

    # Optional
    par0.add_argument('--name', metavar='NAME', help='Name')
    par0.add_argument('--uuid', action='store_true', help='Append uuid to name')
    par0.add_argument('--entrypoint', metavar='ENTRYPOINT', help='Override Entrypoint')
    par0.add_argument('--env', metavar='ENV', action='append', help='Append Env')

    # Positional
    par0.add_argument('config', metavar='CONFIG', help='JSON config file')
    par0.add_argument('arguments', metavar='ARGUMENTS', nargs=argparse.REMAINDER,
                      help='Arguments to pass to container')

    args0 = par0.parse_args(arguments)
    return args0


def config_devices(devices: Sequence[Dict[str, Any]]) -> None:
    ''' Convert config Devices paths into real '''
    if devices is None:
        return

    for device in devices:
        device['PathOnHost'] = os.path.realpath(device['PathOnHost'])

        if not device['PathInContainer']:
            device['PathInContainer'] = device['PathOnHost']


def config_init(config: Dict[str, Any]) -> None:
    ''' Initialize config '''
    if 'Image' not in config:
        print('Image not in config', file=sys.stderr)
        sys.exit(1)

    if ARGS.arguments:
        config['Cmd'] = ARGS.arguments
    if ARGS.entrypoint:
        config['Entrypoint'] = ARGS.entrypoint
    if ARGS.env:
        config['Env'] = config.get('Env', []) + ARGS.env

    host_config = config.get('HostConfig')
    if host_config:
        config_devices(host_config.get('Devices'))


def name_format() -> str:
    ''' Format name '''
    if ARGS.name:
        if ARGS.uuid:
            return '{0:s}-{1:s}'.format(ARGS.name, uuid.uuid4().hex)
        return ARGS.name  # type: ignore
    return uuid.uuid4().hex


def image_exists(tag: str) -> bool:
    ''' Does image exist? '''
    response = SESSION.get(
        url=unixconn.url_format(SOCKET, '/images/{0:s}/json'.format(tag)),
        timeout=TIMEOUT,
    )

    if response.status_code == 200:
        return True
    if response.status_code == 404:
        return False
    raise RuntimeError('{0:s}'.format(json.dumps(
        dict(**unixconn.error(response), **{'tag': tag}))))


def container_remove(name: str) -> None:
    ''' Remove container '''
    response = SESSION.delete(
        url=unixconn.url_format(SOCKET, '/containers/{0:s}'.format(name)),
        timeout=TIMEOUT,
    )

    if response.status_code not in (204, 404):
        raise RuntimeError('{0:s}'.format(json.dumps(
            dict(**unixconn.error(response), **{'name': name}))))


def container_create(name: str, config: Dict[str, Any]) -> Any:
    ''' Create container '''
    response = SESSION.post(  # type: ignore
        url=unixconn.url_format(SOCKET, '/containers/create'),
        headers={'Content-Type': 'application/json'},
        params={'name': name},
        data=json.dumps(config),
        timeout=TIMEOUT,
    )

    if response.status_code != 201:
        raise RuntimeError('{0:s}'.format(json.dumps(
            dict(**unixconn.error(response), **{'name': name, 'config': config}))))

    return response.json()


def main() -> None:
    ''' Main '''
    with open(ARGS.config) as fobj:
        config = json.load(fobj)
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
