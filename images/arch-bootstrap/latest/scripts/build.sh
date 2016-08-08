#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ROOTFS="/tmp/rootfs"
ARCHIVEPATH="/var/lib/bootstrap/archive"

umask 0022

cleanup() {
    rm --recursive "${ROOTFS}"
}
trap cleanup EXIT

mkdir "${ROOTFS}"
pacstrap -d -G -M "${ROOTFS}" $( cat "${SCRIPTDIR}/packages" )
find "${ROOTFS}/var/cache/pacman/pkg" -mindepth 1 -delete

cd "${ARCHIVEPATH}"
tar --create --file='arch-mini-bootstrap.tar.xz' --xz --numeric-owner --xattrs --acls --directory="${ROOTFS}" .
sha512sum arch-mini-bootstrap.tar.xz >| arch-mini-bootstrap.tar.xz.sha512
