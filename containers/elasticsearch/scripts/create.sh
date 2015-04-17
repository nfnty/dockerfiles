#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='elasticsearch' UGID='110000' PRIMPATH='/elasticsearch'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
DATAPATH="${HOSTPATH}/data"
LOGPATH="${HOSTPATH}/logs"

perm_group "${HOSTPATH}" '-maxdepth 0'
perm_group "${CONFIGPATH}"
perm_user "${DATAPATH}"
perm_user "${LOGPATH}"

docker create \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${DATAPATH}:${PRIMPATH}/data" \
    --volume="${LOGPATH}:${PRIMPATH}/logs" \
    --net=none \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    nfnty/arch-elasticsearch:latest

CID="$(docker inspect --format='{{.Id}}' "${CNAME}")"

cd "${BTRFSPATH}/${CID}"
setfattr --name=user.pax.flags --value=em usr/lib/jvm/java-8-openjdk/jre/bin/java
