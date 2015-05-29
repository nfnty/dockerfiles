#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

UPDBIMG="${SCRIPTDIR}/build_base.sh"
UPDIMG="${SCRIPTDIR}/build.sh"

cd "${SCRIPTDIR}"

"${UPDBIMG}" 'arch' 'mini'          'latest'

"${UPDIMG}"  'arch' 'devel'         'latest'
"${UPDIMG}"  'arch' 'java'          'jre8-openjdk-headless'
"${UPDIMG}"  'arch' 'nodejs'        'latest'

"${UPDIMG}"    'arch'    'builder'              'latest'
"${UPDIMG}"    'arch'    'dovecot'              'latest'
"${UPDIMG}"    'arch'    'elasticsearch'        'latest'
"${UPDIMG}"    'arch'    'exim'                 'latest'
"${UPDIMG}"    'arch'    'hostapd'              'latest'
"${UPDIMG}"    'arch'    'kea'                  'latest'
"${UPDIMG}"    'arch'    'kibana'               'latest'
"${UPDIMG}"    'arch'    'logstash'             'latest'
"${UPDIMG}"    'arch'    'nginx'                'latest'
"${UPDIMG}"    'arch'    'ntp'                  'latest'
"${UPDIMG}"    'arch'    'openhab'              'latest'
"${UPDIMG}"    'arch'    'openvpn'              'latest'
"${UPDIMG}"    'arch'    'postgresql'           'latest'
"${UPDIMG}"    'arch'    'powerdns-recursor'    'latest'
"${UPDIMG}"    'arch'    'samba'                'latest'
"${UPDIMG}"    'arch'    'transmission'         'latest'

docker rmi $(docker images --filter='dangling=true' --quiet)
