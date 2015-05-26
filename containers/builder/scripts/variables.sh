#!/usr/bin/bash

CNAME='builder' UGID='99999' PRIMPATH='/builder'
MEMORY='4G' CPU_SHARES='256'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
PKGBUILDPATH="${HOSTPATH}/pkgbuilds"
LOGPATH="${HOSTPATH}/logs"
CRYPTOPATH="${HOSTPATH}/crypto"
GNUPGHOME="${CRYPTOPATH}/gnupg"

STOREPATH="/mnt/2/docker/${CNAME}"
PKGDEST="${STOREPATH}/pkgdest"
SRCDEST="${STOREPATH}/srcdest"
PKGCACHE="${STOREPATH}/pkgcache"
