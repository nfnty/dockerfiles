#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${CONFIGPATH}:/etc/logstash:ro" \
    --volume="${LIBPATH}:/var/lib/logstash:rw" \
    --volume="${LOGPATH}:/var/log/logstash:rw" \
    --volume="${TMPPATH}:/tmp:rw" \
    --volume="${ULOGDPATH}:/mnt/ulogd:ro" \
    --cap-drop='ALL' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --add-host="${CNAME}:127.0.0.1" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-logstash:latest
