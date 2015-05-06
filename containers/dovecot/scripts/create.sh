#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='dovecot' UGID='220000' PRIMPATH='/dovecot'

source "${SCRIPTDIR}/../../scripts/variables.sh"

AUTHPATH="${HOSTPATH}/auth"
CONFIGPATH="${HOSTPATH}/config"
CRYPTOPATH="${HOSTPATH}/crypto"
DATAPATH="${HOSTPATH}/data"
BASEDIRPATH="${DATAPATH}/base_dir"
MAILDIRPATH="${DATAPATH}/maildir"

perm_group "${HOSTPATH}" '-maxdepth 0'
perm_group "${AUTHPATH}"
perm_root "${CONFIGPATH}"
perm_root "${CRYPTOPATH}"
perm_group "${DATAPATH}" '-maxdepth 0'
perm_custom "${BASEDIRPATH}" '0' '0' 'u=rwX,g=rX,o=rX' '' "-not -path ${BASEDIRPATH}/dovecot.conf"
perm_user "${MAILDIRPATH}"

docker create \
    --volume="${AUTHPATH}:${PRIMPATH}/auth:ro" \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${CRYPTOPATH}:${PRIMPATH}/crypto:ro" \
    --volume="${BASEDIRPATH}:${PRIMPATH}/data/base_dir" \
    --volume="${MAILDIRPATH}:${PRIMPATH}/data/maildir" \
    --net=none \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    nfnty/arch-dovecot:latest
