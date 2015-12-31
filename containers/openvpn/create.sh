#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${PATH_CONFIG}:/etc/openvpn:ro" \
    --volume="${PATH_LIB}:/var/lib/openvpn:rw" \
    --volume="${PATH_LOG}:/var/log/openvpn:rw" \
    --volume="${PATH_TMP}:/tmp:rw" \
    --device="${PATH_TUN}:/dev/net/tun:rw" \
    --cap-drop='ALL' \
    --cap-add='NET_ADMIN' \
    --cap-add='NET_RAW' \
    --cap-add='SETGID' \
    --cap-add='SETUID' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-openvpn:latest
