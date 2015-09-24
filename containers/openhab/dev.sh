#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker run \
    --volume="${ADDONPATH}:${PRIMPATH}/addons:ro" \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${DATAPATH}:${PRIMPATH}/data:rw" \
    --volume="${LOGPATH}:${PRIMPATH}/log:rw" \
    --volume="${STATEPATH}:${PRIMPATH}/state:rw" \
    --volume="${TMPPATH}:${PRIMPATH}/tmp:rw" \
    --volume="${WEBAPPPATH}:${PRIMPATH}/webapps:rw" \
    --volume="${WORKPATH}:${PRIMPATH}/work:rw" \
    --device="${TELLSTICKPATH}" \
    --net='bridge' \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    --rm \
    --tty \
    --interactive \
    --user='root' \
    --entrypoint='/usr/bin/bash' \
    nfnty/arch-openhab:latest
