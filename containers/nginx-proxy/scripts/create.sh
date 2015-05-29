#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='nginx-proxy' UGID='160000' PRIMPATH='/nginx'
MEMORY='2G' CPU_SHARES='512'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
CRYPTOPATH="${HOSTPATH}/crypto"
LIBPATH="${HOSTPATH}/lib"
LOGPATH="${HOSTPATH}/log"

perm_user_ro "${CONFIGPATH}"
perm_user_ro "${CRYPTOPATH}"
perm_user_ro "${LIBPATH}" '-maxdepth 0'
perm_user_rw "${LIBPATH}" '-mindepth 1'
perm_user_rw "${LOGPATH}"

docker create \
    --read-only \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${CRYPTOPATH}:${PRIMPATH}/crypto:ro" \
    --volume="${LIBPATH}:${PRIMPATH}/lib:rw" \
    --volume="${LOGPATH}:${PRIMPATH}/log:rw" \
    --cap-drop 'ALL' \
    --cap-add 'NET_BIND_SERVICE' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-nginx:latest
