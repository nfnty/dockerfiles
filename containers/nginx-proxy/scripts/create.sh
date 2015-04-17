#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='nginx-proxy' UGID='160000' PRIMPATH='/nginx'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
CRYPTOPATH="${HOSTPATH}/crypto"

perm_root "${HOSTPATH}" '-maxdepth 0'
perm_root "${CONFIGPATH}"
perm_root "${CRYPTOPATH}"

docker create \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${CRYPTOPATH}:${PRIMPATH}/crypto:ro" \
    --net=none \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    nfnty/arch-nginx:latest
