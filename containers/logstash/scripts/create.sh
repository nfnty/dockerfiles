#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

CNAME='logstash'
UGID=130000
PRIMPATH="/logstash"

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
DATAPATH="${HOSTPATH}/data"
SINCEDBPATH="${DATAPATH}/sincedb"
ULOGDPATH="/var/log/ulogd"

perm_group "${HOSTPATH}" '-maxdepth 0'
perm_group "${CONFIGPATH}"
perm_user "${SINCEDBPATH}"
perm_custom "${ULOGDPATH}" '0' '0' 'u=rwX,g=rX,o=rX'

docker create \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${DATAPATH}:${PRIMPATH}/data" \
    --volume="${ULOGDPATH}:${PRIMPATH}/host/ulogd:ro" \
    --net=none \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    nfnty/arch-logstash:latest

CID="$(docker inspect --format='{{.Id}}' "${CNAME}")"

cd "${BTRFSPATH}/${CID}"
setfattr --name=user.pax.flags --value=em usr/lib/jvm/java-8-openjdk/jre/bin/java
