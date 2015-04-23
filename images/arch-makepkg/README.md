Arch Linux: Makepkg
=====

Builds packages based on PKGBUILDs.

Run the container with the following:

```
usage: pkgbuild.py [-h]
                   (--gpginit | --dbreset | --pkgcleanup | --local | --aur NAME | --git URL | --remote URL)
                   [--pkg PKG [PKG ...]] [--db NAME] [--noclean] [--nosign]
                   [--noforce] [--removeold]
                   [PATH]

Arch Docker package build script

positional arguments:
  PATH                 Optional relative path from /makepkg/pkgbuild to
                       PKGBUILD directory

optional arguments:
  -h, --help           show this help message and exit
  --gpginit            Initialize GnuPG in /makepkg/crypto/gnupg
  --dbreset            Remove database and add the latest packages in
                       /makepkg/pkgdest
  --pkgcleanup         Remove all packages not present in database in
                       /makepkg/pkgdest
  --local              Build from local path in /makepkg/host/pkgbuild
  --aur NAME           Build from AUR
  --git URL            Build from remote git repository
  --remote URL         Build from remote PKGBUILD or archive (tar / tar.gz /
                       tar.xz / gz / xz)
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
