#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${PATH_ETC}:/etc/ntp:ro" \
    --volume="${PATH_LIB}:/var/lib/ntp:rw" \
    --cap-drop='ALL' \
    --cap-add='IPC_LOCK' \
    --cap-add='NET_BIND_SERVICE' \
    --cap-add='SYS_TIME' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-ntp:latest
