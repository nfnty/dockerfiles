#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${PATH_APPS}:/usr/share/webapps/owncloud/apps:rw" \
    --volume="${PATH_CONFIG}:/usr/share/webapps/owncloud/config:rw" \
    --volume="${PATH_DATA}:/usr/share/webapps/owncloud/data:rw" \
    --volume="${PATH_ETC_NGINX}:/etc/nginx:ro" \
    --volume="${PATH_ETC_PHP}:/etc/php:ro" \
    --volume="${PATH_LIB_NGINX}:/var/lib/nginx:rw" \
    --volume="${PATH_LOG_NGINX}:/var/log/nginx:rw" \
    --volume="${PATH_RUN_NGINX}:/run/nginx:rw" \
    --volume="${PATH_RUN_PHP}:/run/php-fpm:rw" \
    --volume="${PATH_TMP}:/tmp:rw" \
    --volume="${PATH_SHARE1}:/mnt/1:rw" \
    --cap-drop='ALL' \
    --cap-add='NET_BIND_SERVICE' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-owncloud:latest
