BNAME='builder'
UGID='99999'
MEMORY='4G'
CPU_SHARES='256'

source "${SCRIPTDIR}/../_misc/variables.sh"
HOSTPATH="${SRVPATH}/${BNAME}"

LIBPATH="${HOSTPATH}/lib"
LOGPATH="${HOSTPATH}/log"
MAKEPKGCONF="${HOSTPATH}/config/makepkg.conf"
PKGCACHEPATH="${HOSTPATH}/pkgcache"
PKGBUILDPATH="${HOSTPATH}/pkgbuild"
