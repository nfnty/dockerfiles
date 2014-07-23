arch-makepkg
============

Docker Archlinux Builder

First build minimal base image by using script over at [nfnty/arch-mini](https://github.com/nfnty/arch-mini)

Build with:

	docker build -t "nfnty/arch-makepkg" .

Run with:

	docker run \
	-v $PKGDEST:/srv/builder/pkg \
	-v $LOCAL:/srv/builder/local:ro \
	--name="$PKGNAME" -t nfnty/arch-makepkg $PKGNAME $FROM

* $PKGDEST = path to package destination
* $LOCAL = path to a folder that contains modified builds
* $PKGNAME = package  name
* $FROM = '1' for AUR or '2' for $LOCAL
