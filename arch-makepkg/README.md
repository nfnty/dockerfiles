arch-makepkg
============

Docker Archlinux Builder

docker build -t "arch-makepkg" .
docker run -v $PKGDESTINATION:/home/builder/pkg -d arch-makepkg

Extract tarball into "makepkg".
