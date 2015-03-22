arch-mini
=========

Arch Linux minimal base image with 11 packages explicitly installed:

* bash
* coreutils
* curl
* filesystem
* gcc-libs
* glibc
* gzip
* pacman
* shadow
* tar
* xz

Build archive by running `scripts/build_archive.sh` as root.

When building the image you need to run [haveged](https://wiki.archlinux.org/index.php/Haveged) or similar if your available random entropy is low.
