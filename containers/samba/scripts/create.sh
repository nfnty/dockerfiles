#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='samba' UGID='140000' PRIMPATH='/samba'
MEMORY='4G' CPU_SHARES='512'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CACHEPATH="${HOSTPATH}/cache"
CONFIGPATH="${HOSTPATH}/config"
LIBPATH="${HOSTPATH}/lib"
LOGPATH="${HOSTPATH}/log"
RUNPATH="${HOSTPATH}/run"
SHARE1='/mnt/1/share'

perm_user_rw "${CACHEPATH}" '' "-and -not -path ${CACHEPATH}/lck*"
perm_custom "${CACHEPATH}/lck" "${UGID}" "${UGID}" 'u=rwX,g=rX,o=rX'
perm_user_ro "${CONFIGPATH}"
perm_user_rw "${LIBPATH}"
perm_user_rw "${LIBPATH}/private"
perm_user_rw "${LOGPATH}"
perm_user_rw "${RUNPATH}"
perm_custom "${SHARE1}" "${UGID}" "${UGID}" 'u=rwX,g=rwXs,o=' '-type d' "-and -not -path ${SHARE1}/torrent*"
perm_custom "${SHARE1}" "${UGID}" "${UGID}" 'u=rwX,g=rwX,o=' '-type f' "-and -not -path ${SHARE1}/torrent*"

docker create \
    --read-only \
    --volume="${CACHEPATH}:${PRIMPATH}/cache:rw" \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${LIBPATH}:${PRIMPATH}/lib:rw" \
    --volume="${LOGPATH}:${PRIMPATH}/log:rw" \
    --volume="${RUNPATH}:${PRIMPATH}/run:rw" \
    --volume="${SHARE1}:${PRIMPATH}/share/1:rw" \
    --cap-drop 'ALL' \
    --cap-add 'NET_BIND_SERVICE' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${1:-"${CNAME}"}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-samba:latest
