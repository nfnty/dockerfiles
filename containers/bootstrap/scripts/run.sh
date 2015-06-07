#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='bootstrap' UGID='0' PRIMPATH='/bootstrap'
MEMORY='4G' CPU_SHARES='256'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CACHEPATH="${HOSTPATH}/cache"
DESTPATH="${SCRIPTDIR}/../../../images/arch-mini/latest/bootstrap"
GNUPGPATH="${HOSTPATH}/crypto/gnupg"

perm_root_rw "${CACHEPATH}"
perm_root_rw "${DESTPATH}"
perm_root_rw "${GNUPGPATH}"

docker run \
    --rm \
    --attach='STDOUT' \
    --attach='STDERR' \
    --read-only \
    --volume="${CACHEPATH}:${PRIMPATH}/cache:rw" \
    --volume="${DESTPATH}:${PRIMPATH}/dest:rw" \
    --volume="${GNUPGPATH}:${PRIMPATH}/crypto/gnupg:rw" \
    --cap-drop 'ALL' \
    --cap-add 'CHOWN' \
    --cap-add 'SYS_CHROOT' \
    --net='bridge' \
    --name="${1:-"${CNAME}"}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-bootstrap:latest
