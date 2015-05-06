#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DOCKERDIR="${SCRIPTDIR}/../latest"
ROOTFS="${TMPDIR}/docker_arch-mini_archive"

if [[ "${UID}" != '0' ]]; then
    echo 'Needs to be run as root.'
    exit 1
fi
if ! hash pacstrap &>/dev/null; then
    echo 'Could not find pacstrap. Run pacman -S arch-install-scripts'
    exit 1
fi
if [[ -d "${ROOTFS}" ]]; then
    echo "${ROOTFS} already exists!"
    exit 1
fi

umask 022
install --directory --owner=root --group=root --mode=755 "${ROOTFS}"

function cleanup {
    echo "Removing ${ROOTFS}"
    rm --recursive "${ROOTFS}"
}
trap cleanup EXIT

pacstrap -c -d -G -M "${ROOTFS}" $( cat "$SCRIPTDIR/packages" )

cd "${DOCKERDIR}/bootstrap"
DATE="$(date --iso-8601)"
tar --create --xz --numeric-owner --xattrs --acls --directory="${ROOTFS}" --file="arch-mini-bootstrap_${DATE}.tar.xz" .
sha512sum "arch-mini-bootstrap_${DATE}.tar.xz" | tee 'sha512sum.txt' "${DOCKERDIR}/checksums/bootstrap_sha512sum.txt"

sed -i "s/^ADD\ bootstrap\/arch-mini-bootstrap_.\+\.tar\.xz\ \/$/ADD\ bootstrap\/arch-mini-bootstrap_${DATE}\.tar\.xz\ \//" \
    "${DOCKERDIR}/Dockerfile"
