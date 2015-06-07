#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='emby' UGID='280000' PRIMPATH='/emby'
MEMORY='4G' CPU_SHARES='1024'

source "${SCRIPTDIR}/../../scripts/variables.sh"

LIBPATH="${HOSTPATH}/lib"
SHARE1="/mnt/1/share"
TMPPATH="${HOSTPATH}/tmp"

perm_user_rw "${LIBPATH}"
perm_user_rw "${TMPPATH}"
perm_custom "${SHARE1}" '140000' '140000' 'u=rwX,g=rwXs,o=' '-type d' "-and -not -path ${SHARE1}/torrent*"
perm_custom "${SHARE1}" '140000' '140000' 'u=rwX,g=rwX,o=' '-type f' "-and -not -path ${SHARE1}/torrent*"

docker create \
    --read-only \
    --volume="${LIBPATH}:${PRIMPATH}/lib:rw" \
    --volume="${SHARE1}/Anime:${PRIMPATH}/media/Anime:ro" \
    --volume="${SHARE1}/Movies:${PRIMPATH}/media/Movies:ro" \
    --volume="${SHARE1}/Series:${PRIMPATH}/media/Series:ro" \
    --volume="${TMPPATH}:${PRIMPATH}/tmp:rw" \
    --cap-drop='ALL' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${1:-"${CNAME}"}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-emby:latest

CID="$( docker inspect --format='{{.Id}}' "${1:-"${CNAME}"}" )"

cd "${BTRFSPATH}/${CID}"
setfattr --name=user.pax.flags --value=em 'usr/bin/mono'
