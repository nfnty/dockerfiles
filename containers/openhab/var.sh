UGID='170000'
MEMORY='4G'
CPU_SHARES='1024'

source "${SCRIPTDIR}/../_misc/variables.sh"

PATH_ADDONS="${PATH_HOST}/addons"
PATH_CONFIG_JETTY="${PATH_HOST}/config_jetty"
PATH_CONFIG_OPENHAB="${PATH_HOST}/config_openhab"
PATH_CONFIG_TELLDUS="${PATH_HOST}/config_telldus/tellstick.conf"
PATH_LIB_OPENHAB="${PATH_HOST}/lib_openhab"
PATH_LIB_TELLDUS="${PATH_HOST}/lib_telldus"
PATH_LOG="${PATH_HOST}/log"
PATH_TMP="${PATH_HOST}/tmp"
PATH_WEBAPPS="${PATH_HOST}/webapps"

PATH_TELLSTICK="$( readlink --canonicalize /dev/tellstickduo0 )"
