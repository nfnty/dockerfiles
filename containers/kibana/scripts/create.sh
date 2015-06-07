#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='kibana' UGID='120000' PRIMPATH='/kibana'
MEMORY='1G' CPU_SHARES='512'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"

perm_user_ro "${CONFIGPATH}"

docker create \
    --read-only \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --cap-drop 'ALL' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${1:-"${CNAME}"}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-kibana:latest

CID="$( docker inspect --format='{{.Id}}' "${1:-"${CNAME}"}" )"

cd "${BTRFSPATH}/${CID}"
setfattr --name=user.pax.flags --value=em kibana/bin/node/bin/node
