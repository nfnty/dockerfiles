#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${CONFIGPATH}:/etc/openvpn:ro" \
    --volume="${LIBPATH}:/var/lib/openvpn:rw" \
    --volume="${LOGPATH}:/var/log/openvpn:rw" \
    --volume="${TMPPATH}:/tmp:rw" \
    --device="${TUNPATH}:/dev/net/tun:rw" \
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
