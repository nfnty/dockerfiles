Arch Linux: Package and database builder
=====

Builds packages based on PKGBUILDs.

####Examples:

* Initialize data container:

        docker create --name='makepkg_data' nfnty/arch-makepkg --gpginit

        docker start makepkg_data

* Check the logs for public key that can be imported on clients for package validation:

        docker logs makepkg_data

* All packages and database are stored in `makepkg_data` persistent storage under `/makepkg/pkgdest`. Retrieve path by issuing:

        docker inspect --format='{{ (index .Volumes "/makepkg/pkgdest") }}' makepkg_data

* Build `yaourt` and remove container afterwards:

        docker run --rm --volumes-from='makepkg_data' nfnty/arch-makepkg --aur yaourt

* Create persistent container that builds `ranger-git` from my git repo [nfnty/pkgbuilds](https://github.com/nfnty/pkgbuilds) and adds it to the database `nfnty`:

        docker run --volumes-from='makepkg_data' --name='makepkg_ranger-git' nfnty/arch-makepkg \
                                  --git 'https://github.com/nfnty/pkgbuilds.git' --db 'nfnty' 'ranger-git'

* Now if `ranger-git` PKGBUILD has been updated or a recompilation is wanted:

        docker start makepkg_ranger-git

####Usage:

```
usage: pkgbuild.py [-h]
                   (--aur NAME | --git URL | --local | --remote URL | --gpginit | --dbreset | --pkgcleanup)
                   [--pkg PKG [PKG ...]] [--db NAME] [--noclean] [--nosign]
                   [--noforce] [--removeold]
                   [PATH]

Arch Docker package build script

positional arguments:
  PATH                 Optional relative path to PKGBUILD directory

optional arguments:
  -h, --help           show this help message and exit
  --aur NAME           Build from AUR
  --git URL            Build from remote git repository
  --local              Build from local path /makepkg/host/pkgbuild
  --remote URL         Build from remote PKGBUILD or archive (tar / tar.gz /
                       tar.xz / gz / xz)
  --gpginit            Initialize GnuPG in /makepkg/crypto/gnupg
  --dbreset            Remove database and add the latest packages in
                       /makepkg/pkgdest
  --pkgcleanup         Remove all packages not present in database in
                       /makepkg/pkgdest
  --pkg PKG [PKG ...]  Name of specific package(s) of group
  --db NAME            Create database in pkgdest root
  --noclean            Do not clean builddir
  --nosign             Do not sign package(s) and database
  --noforce            Do not force overwrite old package
  --removeold          Remove old package after build
```

####Documentation:

* [ArchWiki: PKGBUILD](https://wiki.archlinux.org/index.php/PKGBUILD)
* [ArchWiki: Arch User Repository](https://wiki.archlinux.org/index.php/Arch_User_Repository)
