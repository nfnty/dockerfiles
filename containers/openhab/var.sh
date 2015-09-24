UGID='170000'
PRIMPATH='/openhab'
MEMORY='4G'
CPU_SHARES='1024'

source "${SCRIPTDIR}/../../scripts/variables.sh"

ADDONPATH="${HOSTPATH}/addons"
CONFIGPATH="${HOSTPATH}/config"
DATAPATH="${HOSTPATH}/data"
LOGPATH="${HOSTPATH}/log"
STATEPATH="${HOSTPATH}/state"
TMPPATH="${HOSTPATH}/tmp"
WEBAPPPATH="${HOSTPATH}/webapps"
WORKPATH="${HOSTPATH}/work"

TELLSTICKPATH="$( readlink --canonicalize /dev/tellstickduo0 )"
