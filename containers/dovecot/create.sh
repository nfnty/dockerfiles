#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --read-only \
    --volume="${CONFIGPATH}:/etc/dovecot:ro" \
    --volume="${LIBPATH}:/var/lib/dovecot:rw" \
    --volume="${LOGPATH}:/var/log/dovecot:rw" \
    --volume="${RUNPATH}:/run/dovecot:rw" \
    --volume="${TMPPATH}:/tmp:rw" \
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
