#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${PATH_CACHE}:/var/cache/samba:rw" \
    --volume="${PATH_CONFIG}:/etc/samba:ro" \
    --volume="${PATH_LIB}:/var/lib/samba:rw" \
    --volume="${PATH_LOG}:/var/log/samba:rw" \
    --volume="${PATH_RUN}:/run/samba:rw" \
    --volume="${PATH_SHARE1}:/mnt/1:rw" \
    --cap-drop='ALL' \
    --cap-add='NET_BIND_SERVICE' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-samba:latest
