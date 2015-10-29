#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${LIBPATH}:/var/lib/emby:rw" \
    --volume="${SHARE1}/Anime:/mnt/Anime:ro" \
    --volume="${SHARE1}/Home:/mnt/Home:ro" \
    --volume="${SHARE1}/Movies:/mnt/Movies:ro" \
    --volume="${SHARE1}/Series:/mnt/Series:ro" \
    --volume="${TMPPATH}:/tmp:rw" \
    --cap-drop='ALL' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-emby:latest
