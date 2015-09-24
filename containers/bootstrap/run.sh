#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

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
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-bootstrap:latest
