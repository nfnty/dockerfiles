BNAME='builder'
UGID='99999'
PRIMPATH='/builder'
MEMORY='4G'
CPU_SHARES='256'

source "${SCRIPTDIR}/../../scripts/variables.sh"
HOSTPATH="${SRVPATH}/${BNAME}"

CONFIGPATH="${HOSTPATH}/config"
GNUPGHOME="${HOSTPATH}/crypto/gnupg"
LOGPATH="${HOSTPATH}/logs"
PKGBUILDPATH="${HOSTPATH}/pkgbuilds"
PKGCACHE="${HOSTPATH}/pkgcache"
PKGDEST="${HOSTPATH}/pkgdest"
SRCDEST="${HOSTPATH}/srcdest"
