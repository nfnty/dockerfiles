#!/usr/bin/bash

CNAME='builder' UGID='99999' PRIMPATH='/builder'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
PKGBUILDPATH="${HOSTPATH}/pkgbuilds"
LOGPATH="${HOSTPATH}/logs"
GNUPGHOME="${HOSTPATH}/crypto/gnupg"

STOREPATH="/mnt/2/docker/${CNAME}"
PKGDEST="${STOREPATH}/pkgdest"
SRCDEST="${STOREPATH}/srcdest"
PKGCACHE="${STOREPATH}/pkgcache"

