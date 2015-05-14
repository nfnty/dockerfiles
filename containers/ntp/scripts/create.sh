#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='ntp' UGID='230000' PRIMPATH='/ntp'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
DATAPATH="${HOSTPATH}/data"

perm_group "${HOSTPATH}" '-maxdepth 0'
perm_root "${CONFIGPATH}"
perm_user "${DATAPATH}"

docker create \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${DATAPATH}:${PRIMPATH}/data:rw" \
    --cap-add SYS_TIME \
    --net=none \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    nfnty/arch-ntp:latest
