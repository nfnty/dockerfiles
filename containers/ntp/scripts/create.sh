#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='ntp' UGID='230000' PRIMPATH='/ntp'
MEMORY='512M' CPU_SHARES='2048'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
DATAPATH="${HOSTPATH}/data"

perm_root_ro "${CONFIGPATH}"
perm_user_rw "${DATAPATH}"

docker create \
    --read-only \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${DATAPATH}:${PRIMPATH}/data:rw" \
    --cap-drop 'ALL' \
    --cap-add 'IPC_LOCK' \
    --cap-add 'NET_BIND_SERVICE' \
    --cap-add 'SETGID' \
    --cap-add 'SETUID' \
    --cap-add 'SYS_TIME' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-ntp:latest
