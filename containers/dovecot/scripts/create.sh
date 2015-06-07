#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='dovecot' UGID='220000' PRIMPATH='/dovecot'
UGID2='220001'
MEMORY='2G' CPU_SHARES='1024'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
CRYPTOPATH="${HOSTPATH}/crypto"
MAILDIRPATH="${HOSTPATH}/maildir"
LIBPATH="${HOSTPATH}/lib"
LOGPATH="${HOSTPATH}/log"
RUNPATH="${HOSTPATH}/run"
TMPDIR="${HOSTPATH}/tmp"

perm_user_ro "${CONFIGPATH}"
perm_user_ro "${CRYPTOPATH}"
perm_user_rw "${MAILDIRPATH}"
perm_user_rw "${LIBPATH}"
perm_user_rw "${LOGPATH}"
perm_user_rw "${RUNPATH}" '-maxdepth 0'
perm_user_rw "${TMPDIR}"

docker create \
    --read-only \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${CRYPTOPATH}:${PRIMPATH}/crypto:ro" \
    --volume="${LIBPATH}:${PRIMPATH}/lib:rw" \
    --volume="${LOGPATH}:${PRIMPATH}/log:rw" \
    --volume="${MAILDIRPATH}:${PRIMPATH}/maildir:rw" \
    --volume="${RUNPATH}:${PRIMPATH}/run:rw" \
    --volume="${TMPDIR}:${PRIMPATH}/tmp:rw" \
    --cap-drop='ALL' \
    --cap-add 'NET_BIND_SERVICE' \
    --cap-add 'SYS_CHROOT' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${1:-"${CNAME}"}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-dovecot:latest
