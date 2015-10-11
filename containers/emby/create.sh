#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${LIBPATH}:${PRIMPATH}/lib:rw" \
    --volume="${SHARE1}/Anime:${PRIMPATH}/media/Anime:ro" \
    --volume="${SHARE1}/Home:${PRIMPATH}/media/Home:ro" \
    --volume="${SHARE1}/Movies:${PRIMPATH}/media/Movies:ro" \
    --volume="${SHARE1}/Series:${PRIMPATH}/media/Series:ro" \
    --volume="${TMPPATH}:${PRIMPATH}/tmp:rw" \
    --cap-drop='ALL' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-emby:latest

CID="$( docker inspect --format='{{.Id}}' "${CNAME}" )"
cd "${BTRFSPATH}/${CID}"
setfattr --name=user.pax.flags --value=em 'usr/bin/mono'
