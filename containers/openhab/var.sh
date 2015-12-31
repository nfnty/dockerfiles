UGID='170000'
MEMORY='4G'
CPU_SHARES='1024'

source "${SCRIPTDIR}/../_misc/variables.sh"

PATH_ADDONS="${PATH_HOST}/addons"
PATH_CONFIG="${PATH_HOST}/config"
PATH_ETC_OPENHAB="${PATH_HOST}/etc_openhab"
PATH_ETC_TELLDUS="${PATH_HOST}/etc_telldus"
PATH_LIB_OPENHAB="${PATH_HOST}/lib_openhab"
PATH_LIB_TELLDUS="${PATH_HOST}/lib_telldus"
PATH_LOG="${PATH_HOST}/log"
PATH_TMP="${PATH_HOST}/tmp"
PATH_WEBAPPS="${PATH_HOST}/webapps"

PATH_TELLSTICK="$( readlink --canonicalize /dev/tellstickduo0 )"
