#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

UPD="${SCRIPTDIR}/update.py"

cd "${SCRIPTDIR}"

"${UPD}"       'transmission'
"${UPD}"       'nginx-proxy'
"${UPD}"       'nginx-mirror'
"${UPD}"       'samba'
"${UPD}" --off 'kibana'
"${UPD}" --off 'logstash'
"${UPD}"       'elasticsearch'
systemctl start docker_logstash
systemctl start docker_kibana

systemctl stop docker_openhab
"${UPD}"       'psql-openhab'
systemctl start docker_openhab

"${UPD}" --off 'kea-dhcp4'
"${UPD}"       'hostapd'
systemctl start docker_kea-dhcp4

"${UPD}"       'ntp'
"${UPD}"       'powerdns-recursor'
"${UPD}"       'openvpn-udp'
"${UPD}"       'openvpn-tcp'
"${UPD}"       'dovecot'
"${UPD}"       'exim'
