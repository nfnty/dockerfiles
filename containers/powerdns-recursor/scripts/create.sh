#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='powerdns-recursor' UGID='240000' PRIMPATH='/powerdns'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"

perm_group "${HOSTPATH}" '-maxdepth 0'
perm_group "${CONFIGPATH}"

docker create \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --net=none \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    nfnty/arch-powerdns-recursor:latest
