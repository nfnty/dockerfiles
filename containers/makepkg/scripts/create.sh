#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTDIR}/variables.sh"

PKGNAME="${1}"

docker create \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${PKGBUILDPATH}:${PRIMPATH}/host/pkgbuild:ro" \
    --volume="${PKGDEST}:${PRIMPATH}/pkgdest" \
    --volume="${SRCDEST}:${PRIMPATH}/srcdest" \
    --volume="${LOGPATH}:${PRIMPATH}/logs" \
    --volume="${GNUPGHOME}:${PRIMPATH}/crypto/gnupg" \
    --volume="${PKGCACHE}:/var/cache/pacman/pkg" \
    --net=bridge \
    --name="${CNAME}_${PKGNAME}" \
    nfnty/arch-makepkg:latest \
    ${@:2}
