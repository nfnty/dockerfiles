#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

UPD="${SCRIPTDIR}/update.py"

cd "${SCRIPTDIR}"

"${UPD}"       'transmission'
"${UPD}"       'nginx-proxy'
"${UPD}" --name 'nginx-proxy-wan' 'nginx-proxy'
"${UPD}"       'nginx-mirror'
"${UPD}"       'samba'
"${UPD}" --off 'kibana'
"${UPD}" --off 'logstash'
"${UPD}"       'elasticsearch'
systemctl start docker_logstash
systemctl start docker_kibana

systemctl stop docker_openhab
"${UPD}" --name 'psql-openhab' 'postgresql'
systemctl start docker_openhab

"${UPD}" --off 'kea-dhcp4'
"${UPD}"       'hostapd'
systemctl start docker_kea-dhcp4

"${UPD}"       'ntp'
"${UPD}"       'powerdns-recursor'
"${UPD}"       'dovecot'
"${UPD}"       'exim'

"${UPD}" --name 'openvpn-home-tcp' 'openvpn'
"${UPD}" --name 'openvpn-home-udp' 'openvpn'
"${UPD}" --name 'openvpn-media-udp' 'openvpn'
"${UPD}" --name 'openvpn-admin-tcp' 'openvpn'
"${UPD}" --name 'openvpn-admin-udp' 'openvpn'

"${UPD}"       'emby'
# "${UPD}"       'heka'
