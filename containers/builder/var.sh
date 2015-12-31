BNAME='builder'
UGID='99999'
MEMORY='4G'
CPU_SHARES='256'

source "${SCRIPTDIR}/../_misc/variables.sh"
PATH_HOST="${PATH_SRV}/${BNAME}"

PATH_ETC="${PATH_HOST}/etc"
PATH_LIB="${PATH_HOST}/lib"
PATH_LOG="${PATH_HOST}/log"
PATH_PKGCACHE="${PATH_HOST}/pkgcache"
PATH_PKGBUILD="${PATH_HOST}/pkgbuild"
