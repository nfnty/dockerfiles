#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${ADDONPATH}:/opt/openhab/addons:ro" \
    --volume="${CONFIGPATH_JETTY}:/opt/openhab/etc:ro" \
    --volume="${CONFIGPATH_OPENHAB}:/opt/openhab/configurations:ro" \
    --volume="${CONFIGPATH_TELLDUS}:/etc/tellstick.conf:ro" \
    --volume="${LIBPATH_OPENHAB}:/var/lib/openhab:rw" \
    --volume="${LIBPATH_TELLDUS}:/var/lib/telldus:rw" \
    --volume="${LOGPATH}:/var/log/openhab:rw" \
    --volume="${TMPPATH}:/tmp:rw" \
    --volume="${WEBAPPSPATH}:/opt/openhab/webapps/static:rw" \
    --device="${TELLSTICKPATH}" \
    --cap-drop='ALL' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-openhab-telldus:latest
