#!/usr/bin/bash

set -e
umask 022

if [[ "$UID" != '0' ]]; then
    echo 'Needs to be run as root.'
    exit 1
fi
if ! hash pacstrap &>/dev/null; then
    echo 'Could not find pacstrap. Run pacman -S arch-install-scripts'
    exit 1
fi

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

ROOTFS=$(mktemp -d ${TMPDIR:-/var/tmp}/rootfs-archlinux-XXXXXXXXXX)
chmod 755 "$ROOTFS"

function cleanup {
    echo "Removing $ROOTFS"
    rm -r "$ROOTFS"
}
trap cleanup EXIT

PKGS='bash filesystem glibc pacman shadow'

pacstrap -C "$SCRIPTDIR/etc/pacman.conf" -c -d -G "$ROOTFS" $PKGS haveged procps-ng
arch-chroot "$ROOTFS" /usr/bin/bash -c 'haveged -w 1024; pacman-key --init; pkill -x haveged; pacman-key --populate archlinux; pkill -x gpg-agent; pacman -Rsn --noconfirm haveged procps-ng'

while true; do
    read -e -p 'Enter timezone (e.g. Europe/Berlin or UTC): ' TIMEZONE
    if [[ -n "$TIMEZONE" ]]; then
        if [[ -f "$ROOTFS/usr/share/zoneinfo/$TIMEZONE" ]]; then
            break
        else
            echo "$TIMEZONE is not a valid timezone!"
            continue
        fi
    else
        echo "Timezone can't be empty."
        continue
    fi
done

install -m644 "$SCRIPTDIR/etc/locale.conf" "$ROOTFS/etc/"
install -m644 "$SCRIPTDIR/etc/locale.gen" "$ROOTFS/etc/"
install -m644 "$SCRIPTDIR/etc/pacman.conf" "$ROOTFS/etc/"
arch-chroot "$ROOTFS" /usr/bin/bash -c "ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime"
arch-chroot "$ROOTFS" /usr/bin/bash -c "pacman -S --noconfirm --asdeps --needed sed gzip"
arch-chroot "$ROOTFS" locale-gen

DEV="$ROOTFS/dev"
rm -rf "$DEV"
mkdir -p "$DEV"
mknod -m 666 "$DEV/null" c 1 3
mknod -m 666 "$DEV/zero" c 1 5
mknod -m 666 "$DEV/random" c 1 8
mknod -m 666 "$DEV/urandom" c 1 9
mkdir -m 755 "$DEV/pts"
mkdir -m 1777 "$DEV/shm"
mknod -m 666 "$DEV/tty" c 5 0
mknod -m 600 "$DEV/console" c 5 1
mknod -m 666 "$DEV/tty0" c 4 0
mknod -m 666 "$DEV/full" c 1 7
mknod -m 600 "$DEV/initctl" p
mknod -m 666 "$DEV/ptmx" c 5 2
ln -sf /proc/self/fd "$DEV/fd"

while true; do
    read -e -p 'Name of image? ' CONTAINERNAME
    if [[ -n "$CONTAINERNAME" ]]; then
        break
    else
        echo "Name can't be empty."
        continue
    fi
done

tar --numeric-owner --xattrs --acls -C "$ROOTFS" -c . | docker import - "$CONTAINERNAME"
docker run --rm -t "$CONTAINERNAME" echo Success.
