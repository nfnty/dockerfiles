#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${PATH_CONFIG}/pimd.conf:/etc/pimd.conf:ro" \
    --volume="${PATH_RUN}:/var/run:rw" \
    --cap-drop='ALL' \
    --cap-add='NET_ADMIN' \
    --cap-add='NET_RAW' \
    --net='host' \
    --name="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-pimd:latest
