#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

UPDCON="${SCRIPTDIR}/update.py"

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

systemctl stop docker_openhab
"${UPDCON}"       'psql-openhab'
systemctl start docker_openhab

"${UPDCON}"       'ntp'
"${UPDCON}"       'hostapd'
"${UPDCON}"       'powerdns-recursor'
"${UPDCON}"       'kea-dhcp4'
"${UPDCON}"       'openvpn-udp'
"${UPDCON}"       'openvpn-tcp'
"${UPDCON}"       'dovecot'
"${UPDCON}"       'exim'
