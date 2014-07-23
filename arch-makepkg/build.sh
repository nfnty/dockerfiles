#!/bin/bash

sudo pacman -Syu --noconfirm

if [[ $2 == '1' ]]; then
	curl -O "https://aur.archlinux.org/packages/ra/$1/${1}.tar.gz"
	tar -xzf "${1}.tar.gz"
elif [[ $2 == '2' ]]; then
	cp -r /srv/builder/git/$1 /srv/builder/makepkg/
fi

cd /srv/builder/makepkg/$1
makepkg -s --noconfirm
