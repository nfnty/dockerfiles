Arch Linux: Package and Database Builder
========================================

Builds packages based on `PKGBUILD`.

#### Examples

* Initialize data container:

  ```sh
  docker create --name='builder_data' nfnty/arch-builder --gpginit

  docker start builder_data
  ```

* Check the logs for public key that can be imported on clients for package validation:

  ```sh
  docker logs builder_data
  ```

* All packages and database are stored in `builder_data` persistent storage under `/builder/pkgdest`. Retrieve path by issuing:

  ```sh
  docker inspect --format='{{ (index .Volumes "/builder/pkgdest") }}' builder_data
  ```

* Build `yaourt` and remove container afterwards:

  ```sh
  docker run --rm --volumes-from='builder_data' nfnty/arch-builder --aur yaourt
  ```

* Create persistent container that builds `ranger-git` from my git repo [nfnty/pkgbuilds](https://github.com/nfnty/pkgbuilds) and adds it to the database `nfnty`:

  ```sh
  docker run --volumes-from='builder_data' --name='builder_ranger-git' nfnty/arch-builder \
      --git 'https://github.com/nfnty/pkgbuilds.git' --db 'nfnty' --path 'ranger-git'
  ```

* Now if `ranger-git` PKGBUILD has been updated or a recompilation is wanted:

  ```sh
  docker start builder_ranger-git
  ```

#### Usage

```
usage: builder.py [-h]
                  (--aur NAME | --git URL | --local PATH | --remote URL | --gpginit | --dbreset | --pkgcleanup)
                  [--db NAME] [--path PATH] [--pathfind NAME] [--noclean]
                  [--nosign] [--noforce] [--removeold] [--repackage]
                  [--noprepare]

Arch package build script

optional arguments:
  -h, --help       show this help message and exit
  --aur NAME       Build from AUR
  --git URL        Build from remote git repository
  --local PATH     Build from local path
  --remote URL     Build from remote PKGBUILD or archive
  --gpginit        Initialize GPG in /var/lib/builder/gnupg
  --dbreset        Reset database
  --pkgcleanup     Remove packages not in database
  --db NAME        Create database in pkgdest root
  --path PATH      Relative path to PATH_PKGBUILD directory
  --pathfind NAME  Package name to find
  --noclean        No builddir cleaning
  --nosign         No package/database signing
  --noforce        No overwriting current package
  --removeold      Remove old package after build
  --repackage      Only run package()
  --noprepare      Do not run prepare()
```

#### Documentation

* [ArchWiki: PKGBUILD](https://wiki.archlinux.org/index.php/PKGBUILD)
* [ArchWiki: Arch User Repository](https://wiki.archlinux.org/index.php/Arch_User_Repository)
