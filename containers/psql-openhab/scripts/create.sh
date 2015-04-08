#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

CNAME='psql-openhab'
UGID=180000
PRIMPATH='/postgres'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
CRYPTOPATH="${HOSTPATH}/crypto"
DATAPATH="${HOSTPATH}/data"

perm_group "${HOSTPATH}" '-maxdepth 0'
perm_group "${CONFIGPATH}" '' "-and -not -path ${CONFIGPATH}/private*"
perm_user "${CONFIGPATH}/private"
perm_user "${CRYPTOPATH}"
perm_user "${DATAPATH}"

docker create \
    --volume="${CRYPTOPATH}:${PRIMPATH}/crypto" \
    --volume="${CONFIGPATH}:${PRIMPATH}/config" \
    --volume="${DATAPATH}:${PRIMPATH}/data" \
    --net=none \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    nfnty/arch-postgresql:latest
