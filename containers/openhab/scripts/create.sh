#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='openhab' UGID='170000' PRIMPATH='/openhab'
MEMORY='4G' CPU_SHARES='1024'

source "${SCRIPTDIR}/../../scripts/variables.sh"

ADDONPATH="${HOSTPATH}/addons"
CONFIGPATH="${HOSTPATH}/config"
DATAPATH="${HOSTPATH}/data"
LOGPATH="${HOSTPATH}/log"
STATEPATH="${HOSTPATH}/state"
TMPPATH="${HOSTPATH}/tmp"
WEBAPPPATH="${HOSTPATH}/webapps"
WORKPATH="${HOSTPATH}/work"

perm_user_ro "${ADDONPATH}"
perm_user_ro "${CONFIGPATH}"
perm_user_rw "${DATAPATH}"
perm_user_rw "${LOGPATH}"
perm_user_ro "${STATEPATH}" '-maxdepth 0'
perm_user_rw "${STATEPATH}" '-mindepth 1'
perm_user_rw "${TMPPATH}"
perm_user_ro "${WEBAPPPATH}" '' "-and -not -path ${WEBAPPPATH}/static*"
perm_user_rw "${WEBAPPPATH}/static"
perm_user_rw "${WORKPATH}"

TELLSTICKPATH="$(readlink --canonicalize /dev/tellstickduo0)"

perm_user_rw "${TELLSTICKPATH}"

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

CID="$(docker inspect --format='{{.Id}}' "${CNAME}")"

cd "${BTRFSPATH}/${CID}"
setfattr --name=user.pax.flags --value=em usr/lib/jvm/java-8-openjdk/jre/bin/java
