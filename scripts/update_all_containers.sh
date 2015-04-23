#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

UPDCON="${SCRIPTDIR}/update_container.py"

cd "${SCRIPTDIR}"

"${UPDCON}"       'transmission'
"${UPDCON}"       'nginx-proxy'
"${UPDCON}"       'nginx-mirror'
"${UPDCON}"       'samba'
"${UPDCON}" --off 'kibana'
"${UPDCON}" --off 'logstash'
"${UPDCON}"       'elasticsearch'
systemctl start docker_logstash
systemctl start docker_kibana

"${UPDCON}"       'psql-openhab'
"${UPDCON}"       'openhab'
