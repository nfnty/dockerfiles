#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${PATH_CONFIG}:/etc/logstash:ro" \
    --volume="${PATH_LIB}:/var/lib/logstash:rw" \
    --volume="${PATH_LOG}:/var/log/logstash:rw" \
    --volume="${PATH_TMP}:/tmp:rw" \
    --volume="${PATH_ULOGD}:/mnt/ulogd:ro" \
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
