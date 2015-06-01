#!/usr/bin/python3
''' Print True if age of image is older than 1h '''
from datetime import datetime
import docker
import sys

CLIENT = docker.Client(base_url='unix://var/run/docker.sock', version='auto')

def main():
    ''' Main '''
    if 1 >= len(sys.argv):
        sys.exit(1)
    created = CLIENT.inspect_image(sys.argv[1])['Created']
    created = int(
        datetime.strptime(
            created.split('.')[0], '%Y-%m-%dT%H:%M:%S'
        ).strftime('%s')
    )
    print(3600 < (int(datetime.utcnow().strftime('%s')) - created))

if __name__ == '__main__':
    main()
