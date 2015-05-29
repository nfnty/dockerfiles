#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='elasticsearch' UGID='110000' PRIMPATH='/elasticsearch'
MEMORY='4G' CPU_SHARES='1024'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
DATAPATH="${HOSTPATH}/data"
LOGPATH="${HOSTPATH}/logs"
TMPPATH="${HOSTPATH}/tmp"
WORKPATH="${HOSTPATH}/work"

perm_user_ro "${CONFIGPATH}"
perm_user_rw "${DATAPATH}"
perm_user_rw "${LOGPATH}"
perm_user_rw "${TMPPATH}"
perm_user_rw "${WORKPATH}"

docker create \
    --read-only \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${DATAPATH}:${PRIMPATH}/data:rw" \
    --volume="${LOGPATH}:${PRIMPATH}/logs:rw" \
    --volume="${TMPPATH}:${PRIMPATH}/tmp:rw" \
    --volume="${WORKPATH}:${PRIMPATH}/work:rw" \
    --cap-drop 'ALL' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-elasticsearch:latest

CID="$(docker inspect --format='{{.Id}}' "${CNAME}")"

cd "${BTRFSPATH}/${CID}"
setfattr --name=user.pax.flags --value=em usr/lib/jvm/java-8-openjdk/jre/bin/java
