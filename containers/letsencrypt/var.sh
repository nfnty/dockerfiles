BNAME='letsencrypt'
UGID='160000'
MEMORY='1G'
CPU_SHARES='1024'

source "${SCRIPTDIR}/../_misc/variables.sh"
HOSTPATH="${SRVPATH}/${BNAME}"

CONFIGPATH="${HOSTPATH}/config"
LIBPATH="${HOSTPATH}/lib"
LOGPATH="${HOSTPATH}/log"

WEBROOTPATH="${SRVPATH}/nginx-proxy-wan/webroot/letsencrypt"
