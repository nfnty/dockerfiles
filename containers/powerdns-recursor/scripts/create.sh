#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='powerdns-recursor' UGID='240000' PRIMPATH='/powerdns'
MEMORY='2G' CPU_SHARES='2048'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
RUNPATH="${HOSTPATH}/run"

perm_group "${HOSTPATH}" '-maxdepth 0'
perm_group "${CONFIGPATH}"
perm_group "${RUNPATH}"

docker create \
    --read-only \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${RUNPATH}:${PRIMPATH}/run:rw" \
    --cap-drop 'ALL' \
    --cap-add 'NET_BIND_SERVICE' \
    --cap-add 'SETGID' \
    --cap-add 'SETUID' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-powerdns-recursor:latest
