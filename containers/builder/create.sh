#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${GNUPGHOME}:${PRIMPATH}/gnupg:rw" \
    --volume="${LOGPATH}:${PRIMPATH}/log:rw" \
    --volume="${SRCPATH}:${PRIMPATH}/src:rw" \
    --volume="${PKGBUILDPATH}:${PRIMPATH}/host:ro" \
    --volume="${PKGCACHEPATH}:/var/cache/pacman/pkg:rw" \
    --volume="${PKGPATH}:${PRIMPATH}/pkg:rw" \
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
