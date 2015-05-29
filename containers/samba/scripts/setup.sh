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

perm_user_rw "${CACHEPATH}" '' "-and -not -path ${CACHEPATH}/lck*"
perm_custom "${CACHEPATH}/lck" "${UGID}" "${UGID}" 'u=rwX,g=rX,o=rX'
perm_user_ro "${CONFIGPATH}"
perm_user_rw "${LIBPATH}"
perm_user_rw "${LIBPATH}/private"
perm_user_rw "${LOGPATH}"
perm_user_rw "${RUNPATH}"

docker run \
    --rm \
    --tty \
    --interactive \
    --read-only \
    --volume="${CACHEPATH}:${PRIMPATH}/cache:rw" \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${LIBPATH}:${PRIMPATH}/lib:rw" \
    --volume="${LOGPATH}:${PRIMPATH}/log:rw" \
    --volume="${RUNPATH}:${PRIMPATH}/run:rw" \
    --cap-drop 'ALL' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    --entrypoint '/usr/bin/bash' \
    nfnty/arch-samba:latest
