#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${PATH_LIB}:/var/lib/plexmediaserver:rw" \
    --volume="${PATH_TMP}:/tmp:rw" \
    --volume="${PATH_SHARE1}/Anime:/mnt/Anime:ro" \
    --volume="${PATH_SHARE1}/Home:/mnt/Home:ro" \
    --volume="${PATH_SHARE1}/Movies:/mnt/Movies:ro" \
    --volume="${PATH_SHARE1}/Series:/mnt/Series:ro" \
    --cap-drop='ALL' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-plex:latest
