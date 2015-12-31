#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --volume="${PATH_CONFIG}/makepkg.conf:/etc/makepkg.conf:ro" \
    --volume="${PATH_LIB}:/var/lib/builder:rw" \
    --volume="${PATH_LOG}:/var/log/builder:rw" \
    --volume="${PATH_PKGBUILD}:/mnt/pkgbuild:rw" \
    --volume="${PATH_PKGCACHE}:/var/cache/pacman/pkg:rw" \
    --cap-drop='ALL' \
    --cap-add='FOWNER' \
    --cap-add='SETGID' \
    --cap-add='SETUID' \
    --cap-add='SYS_CHROOT' \
    --cap-add='SYS_RESOURCE' \
    --net='bridge' \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-builder:latest \
    ${@:2}
