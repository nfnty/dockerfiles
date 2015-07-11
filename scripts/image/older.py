#!/usr/bin/python3
''' Print True if age of image is older than amount of seconds '''
from datetime import datetime
import docker
import sys

CLIENT = docker.Client(base_url='unix://run/docker.sock', version='auto')
INAME = sys.argv[1]
SECONDS = int(sys.argv[2])

def main():
    ''' Main '''
    created = CLIENT.inspect_image(INAME)['Created']
    created = int(
        datetime.strptime(
            created.split('.')[0], '%Y-%m-%dT%H:%M:%S'
        ).strftime('%s')
    )
    print(SECONDS < (int(datetime.utcnow().strftime('%s')) - created))

if __name__ == '__main__':
    main()
