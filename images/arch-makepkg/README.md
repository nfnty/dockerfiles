Arch Linux: Makepkg
=====

Builds packages based on PKGBUILDs.

Run the container with the following:

```
usage: pkgbuild.py [-h] (--local | --aur NAME | --git URL | --remote URL)
                   [--pkg PKG [PKG ...]] [--db NAME] [--noclean] [--nosign]
                   [--noforce]
                   [PATH]

Arch Docker package build script

positional arguments:
  PATH                 Optional path to PKGBUILD directory

optional arguments:
  -h, --help           show this help message and exit
  --local              Build from local path
  --aur NAME           Build from AUR
  --git URL            Build from remote git repository
  --remote URL         Build from remote PKGBUILD, directory or archive (tar,
                       gz or xz)
  --pkg PKG [PKG ...]  Name of specific package(s) of group
  --db NAME            Create database in pkgdest root
  --noclean            Do not clean builddir
  --nosign             Do not sign package(s) and database
  --noforce            Do not force overwrite old package
```

####Documentation:

* [ArchWiki: PKGBUILD](https://wiki.archlinux.org/index.php/PKGBUILD)
* [ArchWiki: Arch User Repository](https://wiki.archlinux.org/index.php/Arch_User_Repository)
