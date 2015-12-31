#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${PATH_CONFIG}:/etc/kea:ro" \
    --volume="${PATH_LIB}:/var/lib/kea:rw" \
    --volume="${PATH_LOG}:/var/log/kea:rw" \
    --volume="${PATH_RUN}:/run/kea:rw" \
    --cap-drop='ALL' \
    --cap-add='NET_BIND_SERVICE' \
    --cap-add='NET_RAW' \
    --net='host' \
    --name="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-kea:latest
