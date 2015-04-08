#!/usr/bin/bash

CNAME='makepkg'
PRIMPATH='/makepkg'
UGID=99999

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
PKGBUILDPATH="${HOSTPATH}/pkgbuilds"
LOGPATH="${HOSTPATH}/logs"
GNUPGHOME="${HOSTPATH}/crypto/gnupg"

STOREPATH='/mnt/2/docker/makepkg'
PKGDEST="${STOREPATH}/pkgdest"
SRCDEST="${STOREPATH}/srcdest"
PKGCACHE="${STOREPATH}/pkgcache"

