UGID='0'
MEMORY='4G'
CPU_SHARES='256'

source "${SCRIPTDIR}/../_misc/variables.sh"

PATH_ARCHIVE="$( cd "${SCRIPTDIR}" && git rev-parse --show-toplevel )/images/arch-mini/latest/bootstrap"
PATH_GNUPG="${PATH_HOST}/gnupg"
PATH_PKGCACHE="${PATH_HOST}/pkgcache"
PATH_TMP="${PATH_HOST}/tmp"
