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

perm_root "${HOSTPATH}" '-maxdepth 0'
perm_custom "${CACHEPATH}" '0' '0' 'u=rwX,g=rX,o=rX' '' "-and -not -path ${CACHEPATH}/msg*"
perm_custom "${CACHEPATH}/msg" '0' '0' 'u=rwX,g=,o='
perm_root "${CONFIGPATH}"
perm_root "${LIBPATH}"
perm_root "${LOGPATH}"
perm_custom "${RUNPATH}" '0' '0' 'u=rwX,g=rX,o=rX' '' "-and -not -path ${RUNPATH}/samba/ncalrpc/np*"
perm_root "${RUNPATH}/samba/ncalrpc/np"
perm_custom "${SHARE1}" "${UGID}" "${UGID}" 'u=rwX,g=rwXs,o=rX' '-maxdepth 0'
perm_custom "${SHARE1}" "${UGID}" "${UGID}" 'u=rwX,g=rwX,o=' '-mindepth 1 -type f' "-and -not -path ${SHARE1}/torrent*"
perm_custom "${SHARE1}" "${UGID}" "${UGID}" 'u=rwX,g=rwXs,o=' '-mindepth 1 -type d' "-and -not -path ${SHARE1}/torrent*"

docker create \
    --read-only \
    --volume="${CACHEPATH}:${PRIMPATH}/cache:rw" \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${LIBPATH}:${PRIMPATH}/lib:rw" \
    --volume="${LOGPATH}:${PRIMPATH}/log:rw" \
    --volume="${RUNPATH}:${PRIMPATH}/run:rw" \
    --volume="${SHARE1}:/share/1:rw" \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-samba:latest
