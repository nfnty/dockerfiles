#!/usr/bin/bash

CNAME='builder' UGID='99999' PRIMPATH='/builder'
MEMORY='4G' CPU_SHARES='256'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
CRYPTOPATH="${HOSTPATH}/crypto"
GNUPGHOME="${CRYPTOPATH}/gnupg"
LOGPATH="${HOSTPATH}/logs"
PKGBUILDPATH="${HOSTPATH}/pkgbuilds"

STOREPATH="/mnt/2/docker/${CNAME}"
SRCDEST="${STOREPATH}/srcdest"
PKGCACHE="${STOREPATH}/pkgcache"
PKGDEST="${STOREPATH}/pkgdest"
