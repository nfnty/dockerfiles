#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

CNAME='openhab'
UGID=170000
PRIMPATH="/openhab"

source "${SCRIPTDIR}/../../scripts/variables.sh"

ADDONPATH="${HOSTPATH}/addons"
CONFIGPATH="${HOSTPATH}/config"
WEBAPPPATH="${HOSTPATH}/webapps"

perm_group "${HOSTPATH}" '-maxdepth 0'
perm_group "${ADDONPATH}"
perm_group "${CONFIGPATH}"
perm_group "${WEBAPPPATH}" '' "-and -not -path ${WEBAPPPATH}/static*"
perm_user "${WEBAPPPATH}/static"

TELLSTICKPATH="$(readlink --canonicalize /dev/tellstickduo0)"

perm_user "${TELLSTICKPATH}"

docker create \
    --volume="${ADDONPATH}:${PRIMPATH}/addons:ro" \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${WEBAPPPATH}:${PRIMPATH}/webapps" \
    --device="${TELLSTICKPATH}" \
    --net=none \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    nfnty/arch-openhab:latest

CID="$(docker inspect --format='{{.Id}}' "${CNAME}")"

cd "${BTRFSPATH}/${CID}"
setfattr --name=user.pax.flags --value=em usr/lib/jvm/java-8-openjdk/jre/bin/java
