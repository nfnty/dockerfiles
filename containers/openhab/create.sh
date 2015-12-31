#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${PATH_ADDONS}:/opt/openhab/addons:ro" \
    --volume="${PATH_CONFIG_JETTY}:/opt/openhab/etc:ro" \
    --volume="${PATH_CONFIG_OPENHAB}:/opt/openhab/configurations:ro" \
    --volume="${PATH_CONFIG_TELLDUS}:/etc/tellstick.conf:ro" \
    --volume="${PATH_LIB_OPENHAB}:/var/lib/openhab:rw" \
    --volume="${PATH_LIB_TELLDUS}:/var/lib/telldus:rw" \
    --volume="${PATH_LOG}:/var/log/openhab:rw" \
    --volume="${PATH_TMP}:/tmp:rw" \
    --volume="${PATH_WEBAPPS}:/opt/openhab/webapps/static:rw" \
    --device="${PATH_TELLSTICK}" \
    --cap-drop='ALL' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-openhab-telldus:latest
