#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

if [[ "$1" == 'local' ]]; then
    cd "$PRIMPATH/host/pkgbuild"
    if [[ "$#" -eq 2 ]]; then
        cd "$2"
    fi
elif [[ "$1" == 'aur' ]]; then
    cd "$PRIMPATH/pkgbuild"
    curl "https://aur.archlinux.org/packages/${2:0:2}/$2/${2}.tar.gz" | \
        tar --extract --gzip --strip-components=1 --file=-
elif [[ "$1" == 'git' ]]; then
    cd "$PRIMPATH/pkgbuild"
    git clone "$2" .
    if [[ "$#" -eq 3 ]]; then
        cd "$3"
    fi
elif [[ "$1" == 'remote' ]]; then
    cd "$PRIMPATH/pkgbuild"

    filename="${2##*/}"
    extension="${filename##*.}"
    unset filename
    if [[ "$extension" == 'gz' ]]; then
        curl "$2" | \
            tar --extract --gzip --strip-components=1 --file=-
    elif [[ "$extension" == 'xz' ]]; then
        curl "$2" | \
            tar --extract --xz --strip-components=1 --file=-
    elif [[ "$extension" == 'PKGBUILD' ]]; then
        curl -O "$2"
    else
        echo 'Incorrect file needs to be PKGBUILD, gz or xz!'
        exit 1
    fi
    unset extension

    if [[ "$#" -eq 3 ]]; then
        cd "$3"
    fi
else
    echo 'Fail: Invalid arguments'
    exit 1
fi

/usr/bin/makepkg --config '/makepkg/config/makepkg.conf' --noconfirm --log --syncdeps
