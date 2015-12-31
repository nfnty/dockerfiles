BNAME='letsencrypt'
UGID='160000'
MEMORY='1G'
CPU_SHARES='1024'

source "${SCRIPTDIR}/../_misc/variables.sh"
PATH_HOST="${PATH_SRV}/${BNAME}"

PATH_CONFIG="${PATH_HOST}/config"
PATH_LIB="${PATH_HOST}/lib"
PATH_LOG="${PATH_HOST}/log"

PATH_WEBROOT="${PATH_SRV}/nginx-proxy-wan/webroot/letsencrypt"
