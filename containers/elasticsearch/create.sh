#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${PATH_CONFIG}:/opt/elasticsearch/config:ro" \
    --volume="${PATH_LIB}:/var/lib/elasticsearch:rw" \
    --volume="${PATH_LOG}:/var/log/elasticsearch:rw" \
    --volume="${PATH_PLUGIN}:/opt/elasticsearch/plugins:ro" \
    --volume="${PATH_TMP}:/tmp:rw" \
    --cap-drop='ALL' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --add-host="${CNAME}:127.0.0.1" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-elasticsearch:latest
