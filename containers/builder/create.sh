#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --volume="${MAKEPKGCONF}:/etc/makepkg.conf:ro" \
    --volume="${LIBPATH}:/var/lib/builder:rw" \
    --volume="${LOGPATH}:/var/log/builder:rw" \
    --volume="${PKGBUILDPATH}:/mnt/pkgbuild:rw" \
    --volume="${PKGCACHEPATH}:/var/cache/pacman/pkg:rw" \
    --cap-drop 'ALL' \
    --cap-add 'FOWNER' \
    --cap-add 'SETGID' \
    --cap-add 'SETUID' \
    --cap-add 'SYS_CHROOT' \
    --net='bridge' \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-builder:latest \
    ${@:2}
