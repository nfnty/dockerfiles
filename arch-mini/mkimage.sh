#!/usr/bin/env bash

set -e
umask 022

function cleanup {
	echo "Removing $ROOTFS"
	rm -r $ROOTFS
}

hash pacstrap &>/dev/null || {
    echo "Could not find pacstrap. Run pacman -S arch-install-scripts"
    exit 1
}

read -e -p "Name of the container? " CONNAME
if [[ -z "$CONNAME" ]]; then
	echo "Container name can't be empty."
	exit 1
fi
read -e -p "Enter timezone (e.g. Europe/Berlin or UTC): " TIMEZONE
if [[ -z "$TIMEZONE" ]]; then
	echo "Timezone can't be empty."
	exit 1
fi

ROOTFS=$(mktemp -d ${TMPDIR:-/var/tmp}/rootfs-archlinux-XXXXXXXXXX)
chmod 755 $ROOTFS

trap cleanup EXIT

PKGS='bash filesystem glibc pacman shadow'

pacstrap -C ./pacman.conf -c -d -G $ROOTFS $PKGS haveged procps-ng
arch-chroot $ROOTFS /bin/sh -c "haveged -w 1024; pacman-key --init; pkill -x haveged; pacman -Rsn --noconfirm haveged procps-ng; pacman-key --populate archlinux"

if [[ ! -f "$ROOTFS/usr/share/zoneinfo/$TIMEZONE" ]]; then
	echo "$TIMEZONE is not a valid timezone!"
	exit 1
fi

arch-chroot $ROOTFS /bin/sh -c "ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime"
echo 'LANG="en_US.UTF-8"' > $ROOTFS/etc/locale.conf
echo 'en_US.UTF-8 UTF-8' > $ROOTFS/etc/locale.gen
arch-chroot $ROOTFS /bin/sh -c "pacman -S --noconfirm --asdeps --needed sed gzip"
arch-chroot $ROOTFS locale-gen
arch-chroot $ROOTFS /bin/sh -c "pacman -Rsn --noconfirm gzip"

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

tar --numeric-owner -C $ROOTFS -c . | docker import - $CONNAME
docker run --rm -i -t $CONNAME echo Success.
