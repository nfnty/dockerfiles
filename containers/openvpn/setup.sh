#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker run \
    --read-only \
    --volume="${PATH_ETC}:/etc/openvpn:rw" \
    --cap-drop='ALL' \
    --net='none' \
    --rm \
    --attach='STDOUT' \
    --attach='STDERR' \
    --user="${UGID}" \
    --entrypoint='/usr/bin/openvpn' \
    nfnty/arch-openvpn:latest \
    --genkey --secret /etc/openvpn/ssl/ta.key
