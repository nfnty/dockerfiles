#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='plex' UGID='280000' PRIMPATH='/plex'
MEMORY='4G' CPU_SHARES='1024'

source "${SCRIPTDIR}/../../scripts/variables.sh"

APPSUPPORTPATH="${HOSTPATH}/appsupport"
LIBPATH="${HOSTPATH}/lib"
TMPPATH="${HOSTPATH}/tmp"

perm_user_rw "${APPSUPPORTPATH}"
perm_user_rw "${LIBPATH}"
perm_user_rw "${TMPPATH}"

docker create \
    --read-only \
    --volume="${APPSUPPORTPATH}:${PRIMPATH}/appsupport:rw" \
    --volume="${LIBPATH}:${PRIMPATH}/lib:rw" \
    --volume="${TMPPATH}:${PRIMPATH}/tmp:rw" \
    --cap-drop='ALL' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${1:-"${CNAME}"}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-plex:latest

CID="$( docker inspect --format='{{.Id}}' "${1:-"${CNAME}"}" )"

cd "${BTRFSPATH}/${CID}"
setfattr --name=user.pax.flags --value=em 'plex/bin/Plex Media Server'
setfattr --name=user.pax.flags --value=em 'plex/bin/Plex DLNA Server'
setfattr --name=user.pax.flags --value=em 'plex/bin/Resources/Python/bin/python'
