''' requests Unix socket connection '''

import socket
from typing import Any, Dict, Optional, Tuple

import requests.adapters
import urllib3  # type: ignore


__all__ = ['session', 'url_format', 'error']


class HTTPConnection(urllib3.connection.HTTPConnection):  # type: ignore
    ''' Socket HTTP Connection '''
    def __init__(self, url: str, timeout: int) -> None:
        super(HTTPConnection, self).__init__('localhost', timeout=timeout)
        self.path_socket = requests.compat.unquote(  # type: ignore
            requests.compat.urlparse(url).netloc)  # type: ignore
        self.timeout = timeout
        self.sock: Optional[socket.socket] = None

    def connect(self) -> None:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.settimeout(self.timeout)
        sock.connect(self.path_socket)
        self.sock = sock


class HTTPConnectionPool(urllib3.connectionpool.HTTPConnectionPool):  # type: ignore
    ''' Socket HTTP Connection Pool '''
    def __init__(self, url: str, timeout: Tuple[int, int]) -> None:
        self.timeout = urllib3.connectionpool.Timeout(connect=timeout[0], read=timeout[1])
        super(HTTPConnectionPool, self).__init__('localhost', timeout=self.timeout)
        self.url = url

    def _new_conn(self) -> HTTPConnection:
        return HTTPConnection(self.url, self.timeout.read_timeout)


class Adapter(requests.adapters.HTTPAdapter):
    ''' Socket Adapter'''
    def __init__(self, timeout: Tuple[int, int]) -> None:
        self.timeout = timeout
        super(Adapter, self).__init__()

    def get_connection(self, url: str, proxies: Any = None) -> HTTPConnection:
        return HTTPConnectionPool(url, self.timeout)


def session(prefix: str = 'http+unix://', timeout_connect: int = 31,
            timeout_read: int = 181) -> requests.Session:
    ''' Requests session '''
    sess = requests.Session()
    sess.mount(prefix, Adapter((timeout_connect, timeout_read)))
    return sess


def url_format(path_socket: str, path: str = '', prefix: str = 'http+unix://') -> str:
    ''' Format URL '''
    return '{0:s}{1:s}{2:s}'.format(
        prefix, requests.compat.quote_plus(path_socket), path)  # type: ignore


def error(response: requests.Response) -> Dict[str, Any]:
    ''' Return error '''
    return {
        'url': response.url, 'headers': dict(response.headers), 'encoding': response.encoding,
        'status_code': response.status_code, 'ok': response.ok, 'reason': response.reason,
        'elapsed': response.elapsed.total_seconds(), 'text': response.text,
    }
