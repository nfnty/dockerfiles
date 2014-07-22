#!/usr/bin/env bash

set -e
umask 022

hash pacstrap &>/dev/null || {
    echo "Could not find pacstrap. Run pacman -S arch-install-scripts"
    exit 1
}

ROOTFS=$(mktemp -d ${TMPDIR:-/var/tmp}/rootfs-archlinux-XXXXXXXXXX)
chmod 755 $ROOTFS

PKGS='bash filesystem glibc pacman shadow'
PKGEXTRA='gzip sed'

pacstrap -C ./pacman.conf -c -d -G $ROOTFS $PKGS $PKGEXTRA  haveged procps-ng
arch-chroot $ROOTFS /bin/sh -c "haveged -w 1024; pacman-key --init; pkill -x haveged; pacman -Rsn --noconfirm haveged procps-ng; pacman-key --populate archlinux"

arch-chroot $ROOTFS /bin/sh -c "ln -s /usr/share/zoneinfo/UTC /etc/localtime"
echo 'LANG="en_US.UTF-8"' > $ROOTFS/etc/locale.conf
echo 'en_US.UTF-8 UTF-8' > $ROOTFS/etc/locale.gen
arch-chroot $ROOTFS locale-gen

cp pacman.conf $ROOTFS/etc/

DEV=$ROOTFS/dev
rm -rf $DEV
mkdir -p $DEV
mknod -m 666 $DEV/null c 1 3
mknod -m 666 $DEV/zero c 1 5
mknod -m 666 $DEV/full c 1 7
mknod -m 666 $DEV/random c 1 8
mknod -m 666 $DEV/urandom c 1 9
mkdir -m 755 $DEV/pts
mkdir -m 1777 $DEV/shm
mknod -m 666 $DEV/tty c 5 0
mknod -m 666 $DEV/tty0 c 4 0
mknod -m 600 $DEV/console c 5 1
mknod -m 600 $DEV/initctl p
mknod -m 666 $DEV/ptmx c 5 2
ln -sf /proc/self/fd $DEV/fd

tar --numeric-owner -C $ROOTFS -c . | docker import - arch-mini
docker run --rm -i -t arch-mini echo Success.
rm -rf $ROOTFS
