#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker run \
    --read-only \
    --volume="${PATH_ARCHIVE}:/var/lib/bootstrap/archive:rw" \
    --volume="${PATH_GNUPG}:/var/lib/bootstrap/gnupg:rw" \
    --volume="${PATH_PKGCACHE}:/var/cache/pacman/pkg:rw" \
    --volume="${PATH_TMP}:/tmp:rw" \
    --cap-drop='ALL' \
    --cap-add='CHOWN' \
    --cap-add='SYS_CHROOT' \
    --cap-add='DAC_OVERRIDE' \
    --net='bridge' \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    --attach='STDOUT' \
    --attach='STDERR' \
    --rm \
    nfnty/arch-bootstrap:latest
