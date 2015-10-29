UGID='170000'
MEMORY='4G'
CPU_SHARES='1024'

source "${SCRIPTDIR}/../_misc/variables.sh"

ADDONPATH="${HOSTPATH}/addons"
CONFIGPATH_JETTY="${HOSTPATH}/config_jetty"
CONFIGPATH_OPENHAB="${HOSTPATH}/config_openhab"
CONFIGPATH_TELLDUS="${HOSTPATH}/config_telldus/tellstick.conf"
LIBPATH_OPENHAB="${HOSTPATH}/lib_openhab"
LIBPATH_TELLDUS="${HOSTPATH}/lib_telldus"
LOGPATH="${HOSTPATH}/log"
TMPPATH="${HOSTPATH}/tmp"
WEBAPPSPATH="${HOSTPATH}/webapps"

TELLSTICKPATH="$( readlink --canonicalize /dev/tellstickduo0 )"
