#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

umask 022

if [[ "${UID}" != '0' ]]; then
    echo 'Needs to be run as root.'
    exit 1
fi
if ! hash pacstrap &>/dev/null; then
    echo 'Could not find pacstrap. Run pacman -S arch-install-scripts'
    exit 1
fi

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

ROOTFS=$(mktemp --directory "${TMPDIR}/rootfs-archlinux-XXXXXXXXXX")
chmod 755 "${ROOTFS}"

function cleanup {
    echo "Removing ${ROOTFS}"
    rm --recursive "${ROOTFS}"
}
trap cleanup EXIT

PKGS='bash coreutils curl filesystem findutils gcc-libs glibc gzip pacman shadow tar xz'

pacstrap -c -d -G -M "${ROOTFS}" ${PKGS}

rm --recursive "${ROOTFS}/dev"
mkdir "${ROOTFS}/dev"
cd "${ROOTFS}/dev"
mkdir --mode=755 pts
mkdir --mode=1777 shm
mknod --mode=666 null c 1 3
mknod --mode=666 zero c 1 5
mknod --mode=666 full c 1 7
mknod --mode=666 random c 1 8
mknod --mode=666 urandom c 1 9
mknod --mode=666 tty c 5 0
mknod --mode=666 tty0 c 4 0
mknod --mode=600 console c 5 1
mknod --mode=600 initctl p
mknod --mode=666 ptmx c 5 2
ln --symbolic '/proc/self/fd' fd

DOCKERDIR="${SCRIPTDIR}/../latest"

cd "${DOCKERDIR}/bootstrap"
DATE="$(date --iso-8601)"
tar --create --xz --numeric-owner --xattrs --acls --directory="${ROOTFS}" --file="arch-mini-bootstrap_${DATE}.tar.xz" .
sha512sum "arch-mini-bootstrap_${DATE}.tar.xz" | tee 'sha512sum.txt' "${DOCKERDIR}/checksums/bootstrap_sha512sum.txt"

sed -i "s/^ADD\ bootstrap\/arch-mini-bootstrap_.\+\.tar\.xz\ \/$/ADD\ bootstrap\/arch-mini-bootstrap_${DATE}\.tar\.xz\ \//" \
    "${DOCKERDIR}/Dockerfile"
