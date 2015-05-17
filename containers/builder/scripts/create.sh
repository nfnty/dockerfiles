#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTDIR}/variables.sh"

PKGNAME="${1}"

docker create \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${PKGBUILDPATH}:${PRIMPATH}/host/pkgbuild:ro" \
    --volume="${PKGDEST}:${PRIMPATH}/pkgdest:rw" \
    --volume="${SRCDEST}:${PRIMPATH}/srcdest:rw" \
    --volume="${LOGPATH}:${PRIMPATH}/logs:rw" \
    --volume="${GNUPGHOME}:${PRIMPATH}/crypto/gnupg:rw" \
    --volume="${PKGCACHE}:/var/cache/pacman/pkg:rw" \
    --net='bridge' \
    --name="${CNAME}_${PKGNAME}" \
    --hostname="${CNAME}_${PKGNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-builder:latest \
    ${@:2}

CID="$(docker inspect --format='{{.Id}}' "${CNAME}_${PKGNAME}")"

cd "${BTRFSPATH}/${CID}"
setfattr --name=user.pax.flags --value=em usr/bin/python3
