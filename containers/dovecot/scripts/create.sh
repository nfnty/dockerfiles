#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='dovecot' UGID='220000' PRIMPATH='/dovecot'
UGID2='220001'
MEMORY='2G' CPU_SHARES='1024'

source "${SCRIPTDIR}/../../scripts/variables.sh"

AUTHPATH="${HOSTPATH}/auth"
CONFIGPATH="${HOSTPATH}/config"
CRYPTOPATH="${HOSTPATH}/crypto"
DATAPATH="${HOSTPATH}/data"
BASEDIRPATH="${DATAPATH}/base_dir"
MAILDIRPATH="${DATAPATH}/maildir"
LIBPATH="${HOSTPATH}/lib"

perm_group "${HOSTPATH}" '-maxdepth 0'
perm_group "${AUTHPATH}"
perm_root "${CONFIGPATH}"
perm_root "${CRYPTOPATH}"
perm_group "${DATAPATH}" '-maxdepth 0'
perm_custom "${BASEDIRPATH}" '0' '0' 'u=rwX,g=rX,o=rX' '-maxdepth 0'
perm_custom "${BASEDIRPATH}" '0' '0' 'u=rwX,g=,o=' '-mindepth 1' \
    "-not -path ${BASEDIRPATH}/dovecot.conf \
    -and -not -path ${BASEDIRPATH}/login* \
    -and -not -path ${BASEDIRPATH}/token-login* \
    -and -not -path ${BASEDIRPATH}/empty"
perm_custom "${BASEDIRPATH}/empty" '0' '0' 'u=rwX,g=rX,o=rX'
perm_custom "${BASEDIRPATH}/login" '0' "${UGID2}" 'u=rwX,g=rX,o='
perm_custom "${BASEDIRPATH}/token-login" '0' "${UGID2}" 'u=rwX,g=rX,o='
perm_user "${MAILDIRPATH}"
perm_group "${LIBPATH}"

docker create \
    --read-only \
    --volume="${AUTHPATH}:${PRIMPATH}/auth:ro" \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${CRYPTOPATH}:${PRIMPATH}/crypto:ro" \
    --volume="${BASEDIRPATH}:${PRIMPATH}/data/base_dir:rw" \
    --volume="${LIBPATH}:${PRIMPATH}/lib:rw" \
    --volume="${MAILDIRPATH}:${PRIMPATH}/data/maildir:rw" \
    --cap-drop='ALL' \
    --cap-add 'NET_BIND_SERVICE' \
    --cap-add 'CHOWN' \
    --cap-add 'SETGID' \
    --cap-add 'SETUID' \
    --cap-add 'SYS_CHROOT' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-dovecot:latest
