arch-makepkg
============

Docker Archlinux Builder

First build minimal base image by using script over at https://github.com/nfnty/arch-mini

Build with:

	docker build -t "arch-makepkg" .

Run with:

	docker run \
	-v $PKGDEST:/srv/builder/pkg \
	-v $LOCAL:/srv/builder/local:ro \
	--name="$PKGNAME" -t arch-makepkg $PKGNAME $FROM

* $PKGDEST = path to package destination
* $LOCAL = path to a folder that contains modified builds
* $PKGNAME = package  name
* $FROM = '1' for pulling from AUR and '2' from modified builds folder
