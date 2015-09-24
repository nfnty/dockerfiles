#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${ADDONPATH}:${PRIMPATH}/addons:ro" \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${DATAPATH}:${PRIMPATH}/data:rw" \
    --volume="${LOGPATH}:${PRIMPATH}/log:rw" \
    --volume="${STATEPATH}:${PRIMPATH}/state:rw" \
    --volume="${TMPPATH}:${PRIMPATH}/tmp:rw" \
    --volume="${WEBAPPPATH}:${PRIMPATH}/webapps:rw" \
    --volume="${WORKPATH}:${PRIMPATH}/work:rw" \
    --device="${TELLSTICKPATH}" \
    --cap-drop 'ALL' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-openhab:latest

CID="$( docker inspect --format='{{.Id}}' "${CNAME}" )"
cd "${BTRFSPATH}/${CID}"
setfattr --name=user.pax.flags --value=em usr/lib/jvm/java-8-openjdk/jre/bin/java
