#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='exim' UGID='250000' PRIMPATH='/exim'
MEMORY='2G' CPU_SHARES='1024'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
CRYPTOPATH="${HOSTPATH}/crypto"
LOGPATH="${HOSTPATH}/log"
SPOOLPATH="${HOSTPATH}/spool"

perm_rg_ro "${CONFIGPATH}"
perm_user_ro "${CRYPTOPATH}"
perm_ur_rw "${LOGPATH}"
perm_user_rw "${SPOOLPATH}"

docker create \
    --read-only \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${CRYPTOPATH}:${PRIMPATH}/crypto:ro" \
    --volume="${LOGPATH}:${PRIMPATH}/log:rw" \
    --volume="${SPOOLPATH}:${PRIMPATH}/spool:rw" \
    --cap-drop='ALL' \
    --cap-add 'NET_BIND_SERVICE' \
    --cap-add 'SETGID' \
    --cap-add 'SETUID' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="cloud.nfnty.se" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-exim:latest
