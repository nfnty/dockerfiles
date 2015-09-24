#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --cap-drop 'ALL' \
    --cap-add 'NET_ADMIN' \
    --cap-add 'NET_RAW' \
    --net='host' \
    --name="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    --entrypoint='/usr/bin/hostapd' \
    nfnty/arch-hostapd:latest \
    /hostapd/config/wlan_24n0/hostapd.conf \
    /hostapd/config/wlan_50n0/hostapd.conf
