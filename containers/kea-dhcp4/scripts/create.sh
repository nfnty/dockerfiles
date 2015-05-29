#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='kea-dhcp4' UGID='260000' PRIMPATH='/kea'
MEMORY='1G' CPU_SHARES='2048'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CACHEPATH="${HOSTPATH}/cache"
CONFIGPATH="${HOSTPATH}/config"
CRYPTOPATH="${HOSTPATH}/crypto"
DATAPATH="${HOSTPATH}/data"

perm_user_rw "${CACHEPATH}"
perm_user_ro "${CONFIGPATH}"
perm_user_ro "${CRYPTOPATH}"
perm_user_rw "${DATAPATH}"

docker create \
    --read-only \
    --volume="${CACHEPATH}:${PRIMPATH}/cache:rw" \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${CRYPTOPATH}:${PRIMPATH}/crypto:ro" \
    --volume="${DATAPATH}:${PRIMPATH}/data:rw" \
    --cap-drop 'ALL' \
    --cap-add 'NET_BIND_SERVICE' \
    --cap-add 'NET_RAW' \
    --net='host' \
    --name="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    --entrypoint='/usr/bin/kea-dhcp4' \
    nfnty/arch-kea:latest \
    -c '/kea/config/kea.conf'
