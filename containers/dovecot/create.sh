#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${PATH_ETC}:/etc/dovecot:ro" \
    --volume="${PATH_LIB}:/var/lib/dovecot:rw" \
    --volume="${PATH_LOG}:/var/log/dovecot:rw" \
    --volume="${PATH_RUN}:/run/dovecot:rw" \
    --volume="${PATH_TMP}:/tmp:rw" \
    --cap-drop='ALL' \
    --cap-add='NET_BIND_SERVICE' \
    --cap-add='SYS_CHROOT' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-dovecot:latest
