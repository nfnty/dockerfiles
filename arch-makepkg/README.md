arch-makepkg
============

Docker Archlinux Builder

First create and import base image by using script over at https://github.com/nfnty/arch-mini

	docker build -t "arch-makepkg" .
	tar -xzf $TARBALL makepkg
	docker run -v $PKGDEST:/home/builder/pkg -d arch-makepkg
