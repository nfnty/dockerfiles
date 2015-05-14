#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='openvpn-udp' UGID='190000' PRIMPATH='/openvpn'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
CRYPTOPATH="${HOSTPATH}/crypto"
DATAPATH="${HOSTPATH}/data"
DEVPATH="${HOSTPATH}/dev"
TUNPATH="${DEVPATH}/tun"
SCRIPTSPATH="${HOSTPATH}/scripts"

perm_group "${HOSTPATH}" '-maxdepth 0'
perm_root "${CONFIGPATH}"
perm_root "${CRYPTOPATH}"
perm_custom "${DEVPATH}" '0' '0' 'u=rwX,g=rX,o=rX' '-maxdepth 0'
perm_custom "${TUNPATH}" '0' '0' 'u=rw,g=rw,o=rw'
perm_user "${DATAPATH}"
perm_root "${SCRIPTSPATH}"

docker create \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${CRYPTOPATH}:${PRIMPATH}/crypto:ro" \
    --volume="${DATAPATH}:${PRIMPATH}/data:rw" \
    --volume="${SCRIPTSPATH}:${PRIMPATH}/scripts:ro" \
    --device="${TUNPATH}:/dev/net/tun:rw" \
    --cap-add NET_ADMIN \
    --net=none \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    nfnty/arch-openvpn:latest
