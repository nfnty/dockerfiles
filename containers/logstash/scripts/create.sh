#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='logstash' UGID='130000' PRIMPATH='/logstash'
MEMORY='4G' CPU_SHARES='1024'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
BUNDLEPATH="${HOSTPATH}/bundle"
SINCEDBPATH="${HOSTPATH}/sincedb"
TMPPATH="${HOSTPATH}/tmp"
ULOGDPATH="/var/log/ulogd"

perm_user_ro "${CONFIGPATH}"
perm_user_rw "${BUNDLEPATH}"
perm_user_rw "${SINCEDBPATH}"
perm_user_rw "${TMPPATH}"
perm_custom "${ULOGDPATH}" '0' '0' 'u=rwX,g=rX,o=rX'

docker create \
    --read-only \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${BUNDLEPATH}:${PRIMPATH}/bundle:rw" \
    --volume="${SINCEDBPATH}:${PRIMPATH}/sincedb:rw" \
    --volume="${TMPPATH}:${PRIMPATH}/tmp:rw" \
    --volume="${ULOGDPATH}:${PRIMPATH}/host/ulogd:ro" \
    --cap-drop 'ALL' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${1:-"${CNAME}"}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-logstash:latest

CID="$( docker inspect --format='{{.Id}}' "${1:-"${CNAME}"}" )"

cd "${BTRFSPATH}/${CID}"
setfattr --name=user.pax.flags --value=em usr/lib/jvm/java-8-openjdk/jre/bin/java
