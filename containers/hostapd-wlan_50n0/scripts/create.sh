#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='hostapd-wlan_50n0' UGID='0' PRIMPATH='/hostapd'
MEMORY='1G' CPU_SHARES='2048'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"

perm_root "${HOSTPATH}" '-maxdepth 0'
perm_root "${CONFIGPATH}"

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
    nfnty/arch-hostapd:latest
