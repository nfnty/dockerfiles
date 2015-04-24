#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

UPDBIMG="${SCRIPTDIR}/build_baseimage.sh"
UPDIMG="${SCRIPTDIR}/build_image.sh"

cd "${SCRIPTDIR}"

"${UPDBIMG}" 'arch' 'mini'          'latest'

"${UPDIMG}"  'arch' 'devel'         'latest'
"${UPDIMG}"  'arch' 'java'          'jre8-openjdk-headless'

"${UPDIMG}"  'arch' 'elasticsearch' 'latest'
"${UPDIMG}"  'arch' 'kibana'        'latest'
"${UPDIMG}"  'arch' 'logstash'      'latest'
"${UPDIMG}"  'arch' 'builder'       'latest'
"${UPDIMG}"  'arch' 'nginx'         'latest'
"${UPDIMG}"  'arch' 'openhab'       'latest'
"${UPDIMG}"  'arch' 'postgresql'    'latest'
"${UPDIMG}"  'arch' 'samba'         'latest'
"${UPDIMG}"  'arch' 'transmission'  'latest'

docker rmi $(docker images --filter='dangling=true' --quiet)
