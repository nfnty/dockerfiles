''' requests Unix socket connection '''

import socket

import requests.adapters
import urllib3


__all__ = ['session', 'url_format', 'error']


class HTTPConnection(urllib3.connection.HTTPConnection):
    ''' Socket HTTP Connection '''
    def __init__(self, url, timeout):
        super(HTTPConnection, self).__init__('localhost', timeout=timeout)
        self.path_socket = requests.compat.unquote(requests.compat.urlparse(url).netloc)
        self.timeout = timeout

    def connect(self):
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.settimeout(self.timeout)
        sock.connect(self.path_socket)
        self.sock = sock


class HTTPConnectionPool(urllib3.connectionpool.HTTPConnectionPool):
    ''' Socket HTTP Connection Pool '''
    def __init__(self, url, timeout):
        self.timeout = urllib3.connectionpool.Timeout(connect=timeout[0], read=timeout[1])
        super(HTTPConnectionPool, self).__init__('localhost', timeout=self.timeout)
        self.url = url

    def _new_conn(self):
        return HTTPConnection(self.url, self.timeout.read_timeout)


class Adapter(requests.adapters.HTTPAdapter):
    ''' Socket Adapter'''
    def __init__(self, timeout):
        self.timeout = timeout
        super(Adapter, self).__init__()

    def get_connection(self, url, proxies=None):
        return HTTPConnectionPool(url, self.timeout)


def session(prefix='http+unix://', timeout_connect=31, timeout_read=181):
    ''' Requests session '''
    sess = requests.Session()
    sess.mount(prefix, Adapter((timeout_connect, timeout_read)))
    return sess


def url_format(path_socket, path, prefix='http+unix://'):
    ''' Format URL '''
    return '{0:s}{1:s}{2:s}'.format(prefix, requests.compat.quote_plus(path_socket), path)


def error(response):
    ''' Return error '''
    return {
        'url': response.url, 'headers': dict(response.headers), 'encoding': response.encoding,
        'status_code': response.status_code, 'ok': response.ok, 'reason': response.reason,
        'elapsed': response.elapsed.total_seconds(), 'text': response.text,
    }
