''' API '''

import json
import requests

from utils.unixconn import UnixAdapter
from utils.meta import META

__all__ = ['request', 'get', 'post', 'delete', 'decode_attach', 'decode_build']


URL = 'http+docker://localunixsocket'
SESSION = requests.Session()
SESSION.mount(
    'http+docker://',
    UnixAdapter('http+unix://{0:s}'.format(META['Socket']),
                (META['Limits']['TimeoutConnect'], META['Limits']['TimeoutRead'])),
)


def request(function, *args, **kwargs):
    ''' Wrap requests '''
    try:
        response = function(*args, **kwargs)
        response.raise_for_status()
    except (requests.exceptions.Timeout, requests.exceptions.HTTPError) as error:
        raise RuntimeError('{0:s}\n{1:s}'.format(str(error), str(error.response.content)))
    return response


def get(url_rel, params=None, stream=False):
    ''' get socket request '''
    response = SESSION.get(
        '{0:s}{1:s}'.format(URL, url_rel),
        headers={'Content-Type': 'application/json'},
        params=params,
        stream=stream,
        timeout=(META['Limits']['TimeoutConnect'], META['Limits']['TimeoutRead']),
    )
    return response


def post(url_rel, params=None, data=None, stream=False, headers=None):
    ''' post socket request '''
    if not headers:
        headers = {'Content-Type': 'application/json'}

    response = SESSION.post(
        '{0:s}{1:s}'.format(URL, url_rel),
        headers=headers,
        params=params,
        data=data,
        stream=stream,
        timeout=(META['Limits']['TimeoutConnect'], META['Limits']['TimeoutRead']),
    )
    response.raise_for_status()
    return response


def delete(url_rel, params=None):
    ''' post socket request '''
    response = SESSION.delete(
        '{0:s}{1:s}'.format(URL, url_rel),
        headers={'Content-Type': 'application/json'},
        params=params,
        timeout=(META['Limits']['TimeoutConnect'], META['Limits']['TimeoutRead']),
    )
    response.raise_for_status()
    return response


def decode_attach(filedesc):
    ''' attach protocol '''
    while True:
        chunk = filedesc.read(8)
        if not chunk:
            break

        if chunk[0] == 1:
            stream_type = 'stdout'
        elif chunk[0] == 2:
            stream_type = 'stderr'
        else:
            raise RuntimeError('Unknown stream_type {0:s}'.format(str(chunk[0])))

        yield stream_type, \
            filedesc.read(int.from_bytes(chunk[4:], byteorder='big')).decode('UTF-8')


def decode_build(response):
    ''' decode build '''
    for line in response.iter_lines():
        line = line.decode('UTF-8')
        decoded = ''
        try:
            deserial = json.loads(line)
        except json.decoder.JSONDecodeError as error:
            yield False, str(error)
            continue
        if not isinstance(deserial, dict):
            yield False, 'Loaded JSON string is not a dictionary'
            continue

        if 'stream' in deserial:
            decoded += deserial['stream']
            del deserial['stream']
        if deserial:
            decoded += str(deserial) + '\n'

        if 'error' in deserial:
            yield False, decoded
            continue

        yield True, decoded
