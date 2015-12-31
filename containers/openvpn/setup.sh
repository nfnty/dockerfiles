#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker run \
    --read-only \
    --volume="${PATH_CONFIG}:/etc/openvpn:rw" \
    --cap-drop='ALL' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    --rm \
    --attach='STDOUT' \
    --attach='STDERR' \
    --user="${UGID}" \
    --entrypoint='/usr/bin/openvpn' \
    nfnty/arch-openvpn:latest \
    --genkey --secret /etc/openvpn/crypto/ta.key
