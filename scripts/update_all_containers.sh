#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

UPDCON="${SCRIPTDIR}/update_container.sh"

cd "${SCRIPTDIR}"

"${UPDCON}"       'transmission'    'on'
"${UPDCON}"       'nginx-proxy'     'on'
"${UPDCON}"       'nginx-mirror'    'on'
"${UPDCON}"       'samba'           'on'
"${UPDCON}"       'kibana'          'off'
"${UPDCON}"       'logstash'        'off'
"${UPDCON}"       'elasticsearch'   'on'
systemctl start docker_logstash
systemctl start docker_kibana

"${UPDCON}"       'psql-openhab'   'off'
"${UPDCON}"       'openhab'        'off'
# "${UPDCON}"       'makepkg'        'off'
