Arch Linux: Package and database builder
=====

Builds packages based on PKGBUILDs.

####Examples:

* Initialize data container:

        docker create --name='builder_data' nfnty/arch-builder --gpginit

        docker start builder_data

* Check the logs for public key that can be imported on clients for package validation:

        docker logs builder_data

* All packages and database are stored in `builder_data` persistent storage under `/builder/pkgdest`. Retrieve path by issuing:

        docker inspect --format='{{ (index .Volumes "/builder/pkgdest") }}' builder_data

* Build `yaourt` and remove container afterwards:

        docker run --rm --volumes-from='builder_data' nfnty/arch-builder --aur yaourt

* Create persistent container that builds `ranger-git` from my git repo [nfnty/pkgbuilds](https://github.com/nfnty/pkgbuilds) and adds it to the database `nfnty`:

        docker run --volumes-from='builder_data' --name='builder_ranger-git' nfnty/arch-builder \
                                  --git 'https://github.com/nfnty/pkgbuilds.git' --db 'nfnty' --path 'ranger-git'

* Now if `ranger-git` PKGBUILD has been updated or a recompilation is wanted:

        docker start builder_ranger-git

####Usage:

```
usage: pkgbuild.py [-h]
                   (--aur NAME | --git URL | --local | --remote URL | --gpginit | --dbreset | --pkgcleanup)
                   [--pkg PKG [PKG ...]] [--db NAME] [--path PATH] [--noclean]
                   [--nosign] [--noforce] [--removeold]

Arch Docker package build script

optional arguments:
  -h, --help           show this help message and exit
  --aur NAME           Build from AUR
  --git URL            Build from remote git repository
  --local              Build from local path /builder/host/pkgbuild
  --remote URL         Build from remote PKGBUILD or archive (tar / tar.gz /
                       tar.xz / gz / xz)
  --gpginit            Initialize GnuPG in /builder/crypto/gnupg
  --dbreset            Remove database and add the latest packages in
                       /builder/pkgdest
  --pkgcleanup         Remove all packages not present in database in
                       /builder/pkgdest
  --pkg PKG [PKG ...]  Name of specific package(s) of group
  --db NAME            Create database in pkgdest root
  --path PATH          Relative path to PKGBUILD directory
  --noclean            Do not clean builddir
  --nosign             Do not sign package(s) and database
  --noforce            Do not force overwrite old package
  --removeold          Remove old package after build
```

####Documentation:

* [ArchWiki: PKGBUILD](https://wiki.archlinux.org/index.php/PKGBUILD)
* [ArchWiki: Arch User Repository](https://wiki.archlinux.org/index.php/Arch_User_Repository)
