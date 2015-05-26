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
RUNPATH="${HOSTPATH}/run"
TMPDIR="${HOSTPATH}/tmp"

perm_group "${CONFIGPATH}"
perm_root "${CRYPTOPATH}"
perm_user "${MAILDIRPATH}"
perm_group "${LIBPATH}"
perm_custom "${RUNPATH}" '0' '0' 'u=rwX,g=rX,o=rX' '-maxdepth 0'
perm_user "${TMPDIR}"

docker create \
    --read-only \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${CRYPTOPATH}:${PRIMPATH}/crypto:ro" \
    --volume="${LIBPATH}:${PRIMPATH}/lib:rw" \
    --volume="${MAILDIRPATH}:${PRIMPATH}/maildir:rw" \
    --volume="${RUNPATH}:${PRIMPATH}/run:rw" \
    --volume="${TMPDIR}:/tmp:rw" \
    --cap-drop='ALL' \
    --cap-add 'NET_BIND_SERVICE' \
    --cap-add 'CHOWN' \
    --cap-add 'KILL' \
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
