#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${CONFIGPATH}:/etc/kea:ro" \
    --volume="${LIBPATH}:/var/lib/kea:rw" \
    --volume="${LOGPATH}:/var/log/kea:rw" \
    --volume="${RUNPATH}:/run/kea:rw" \
    --cap-drop='ALL' \
    --cap-add='NET_BIND_SERVICE' \
    --cap-add='NET_RAW' \
    --net='host' \
    --name="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-kea:latest
