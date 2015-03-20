#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

'./build_baseimage.sh'   'arch'   'mini'            'latest'

'./build_image.sh'       'arch'   'java'            'jre8-openjdk-headless'
'./build_image.sh'       'arch'   'transmission'    'latest'
'./build_image.sh'       'arch'   'elasticsearch'   'latest'
'./build_image.sh'       'arch'   'kibana'          'latest'
'./build_image.sh'       'arch'   'logstash'        'latest'

'./update_container.sh'   'transmission'    'on'
'./update_container.sh'   'kibana'          'off'
'./update_container.sh'   'logstash'        'off'
'./update_container.sh'   'elasticsearch'   'on'
systemctl start docker_logstash
systemctl start docker_kibana

docker rmi $(docker images --filter='dangling=true' --quiet)
