#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='openvpn-tcp' UGID='190000' PRIMPATH='/openvpn'
MEMORY='2G' CPU_SHARES='512'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
CRYPTOPATH="${HOSTPATH}/crypto"
DATAPATH="${HOSTPATH}/data"
DEVPATH="${HOSTPATH}/dev"
TUNPATH="${DEVPATH}/tun"
SCRIPTSPATH="${HOSTPATH}/scripts"
TMPPATH="${HOSTPATH}/tmp"

perm_root "${CONFIGPATH}"
perm_root "${CRYPTOPATH}"
perm_custom "${DEVPATH}" '0' '0' 'u=rwX,g=rX,o=rX' '-maxdepth 0'
perm_custom "${TUNPATH}" '0' '0' 'u=rw,g=rw,o=rw'
perm_custom "${DATAPATH}" "${UGID}" '0' 'u=rwX,g=rwX,o='
perm_root "${SCRIPTSPATH}"
perm_custom "${TMPPATH}" "${UGID}" '0' 'u=rwX,g=rwX,o='

docker create \
    --read-only \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${CRYPTOPATH}:${PRIMPATH}/crypto:ro" \
    --volume="${DATAPATH}:${PRIMPATH}/data:rw" \
    --volume="${SCRIPTSPATH}:${PRIMPATH}/scripts:ro" \
    --volume="${TMPPATH}:${PRIMPATH}/tmp:rw" \
    --device="${TUNPATH}:/dev/net/tun:rw" \
    --cap-drop 'ALL' \
    --cap-add 'NET_ADMIN' \
    --cap-add 'NET_RAW' \
    --cap-add 'SETGID' \
    --cap-add 'SETUID' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-openvpn:latest
