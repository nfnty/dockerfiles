#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker run \
    --read-only \
    --volume="${CONFIGPATH}:/etc/letsencrypt:rw" \
    --volume="${LIBPATH}:/var/lib/letsencrypt:rw" \
    --volume="${LOGPATH}:/var/log/letsencrypt:rw" \
    --volume="${WEBROOTPATH}:/mnt/webroot:rw" \
    --cap-drop='ALL' \
    --net='bridge' \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    --attach='STDOUT' \
    --attach='STDERR' \
    --rm \
    nfnty/arch-letsencrypt:latest \
    ${@:2}
