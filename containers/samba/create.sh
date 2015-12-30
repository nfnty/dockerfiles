#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${CACHEPATH}:/var/cache/samba:rw" \
    --volume="${CONFIGPATH}:/etc/samba:ro" \
    --volume="${LIBPATH}:/var/lib/samba:rw" \
    --volume="${LOGPATH}:/var/log/samba:rw" \
    --volume="${RUNPATH}:/run/samba:rw" \
    --volume="${SHARE1}:/mnt/1:rw" \
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
