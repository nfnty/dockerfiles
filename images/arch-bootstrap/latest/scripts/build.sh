#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PRIMPATH='/bootstrap'
ROOTFS="${PRIMPATH}/rootfs"
DESTPATH="${PRIMPATH}/dest"
CONFIGPATH="${PRIMPATH}/config"

umask 022
install --directory --owner=root --group=root --mode=755 "${ROOTFS}"
pacstrap -c -d -G -M "${ROOTFS}" $( cat "${CONFIGPATH}/packages" )

cd "${DESTPATH}"
tar --create --xz --numeric-owner --xattrs --acls --directory="${ROOTFS}" --file="arch-mini-bootstrap.tar.xz" .
sha512sum "arch-mini-bootstrap.tar.xz" >| "arch-mini-bootstrap.tar.xz.sha512sum"
