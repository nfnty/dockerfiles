arch-makepkg
============

Docker Archlinux Builder

	docker build -t "arch-makepkg" .
	docker run -v $PKGDEST:/home/builder/pkg -d arch-makepkg
	
	tar -xzf $TARBALL makepkg
