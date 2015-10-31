UGID='0'
MEMORY='4G'
CPU_SHARES='256'

source "${SCRIPTDIR}/../_misc/variables.sh"

ARCHIVEPATH="$( cd "${SCRIPTDIR}" && git rev-parse --show-toplevel )/images/arch-mini/latest/bootstrap"
GNUPGPATH="${HOSTPATH}/gnupg"
PKGCACHEPATH="${HOSTPATH}/pkgcache"
TMPPATH="${HOSTPATH}/tmp"
