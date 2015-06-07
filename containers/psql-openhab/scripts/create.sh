#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='psql-openhab' UGID='180000' PRIMPATH='/postgres'
MEMORY='2G' CPU_SHARES='1024'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CRYPTOPATH="${HOSTPATH}/crypto"
DATAPATH="${HOSTPATH}/data"
RUNPATH="${HOSTPATH}/run"

perm_user_ro "${CRYPTOPATH}"
perm_user_rw "${DATAPATH}"
perm_user_rw "${RUNPATH}"

docker create \
    --read-only \
    --volume="${CRYPTOPATH}:${PRIMPATH}/crypto:ro" \
    --volume="${DATAPATH}:${PRIMPATH}/data:rw" \
    --volume="${RUNPATH}:${PRIMPATH}/run:rw" \
    --cap-drop 'ALL' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${1:-"${CNAME}"}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-postgresql:latest
