arch-makepkg
============

Docker Archlinux Builder

First build minimal base image by using script over at https://github.com/nfnty/arch-mini

	docker build -t "arch-makepkg" .

Run with:

	docker run \
	-v $PKGDEST:/srv/builder/pkg \
	-v $LOCAL:/srv/builder/local:ro \
	--name="$1" -t arch-makepkg $1 $2

$PKGDEST is the path to the folder that you want the built packages to end up.
$LOCAL is the path to a folder that contains modified builds.

$1 is the package  name
$2 is '1' if you want it to pull from AUR and '2' from your modified builds.
