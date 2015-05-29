#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='nginx-mirror' UGID='160000' PRIMPATH='/nginx'
MEMORY='2G' CPU_SHARES='512'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
LIBPATH="${HOSTPATH}/lib"
LOGPATH="${HOSTPATH}/log"
PKGPATH='/mnt/2/docker/builder/pkgdest'

perm_user_ro "${CONFIGPATH}"
perm_user_ro "${LIBPATH}" '-maxdepth 0'
perm_user_rw "${LIBPATH}" '-mindepth 1'
perm_user_rw "${LOGPATH}"
perm_custom "${PKGPATH}" '99999' '99999' 'u=rwX,g=rX,o=rX'

docker create \
    --read-only \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${LIBPATH}:${PRIMPATH}/lib:rw" \
    --volume="${LOGPATH}:${PRIMPATH}/log:rw" \
    --volume="${PKGPATH}:${PRIMPATH}/content/archlinux/nfnty/os/x86_64:ro" \
    --cap-drop 'ALL' \
    --cap-add 'NET_BIND_SERVICE' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-nginx:latest
