#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='openvpn-tcp' UGID='190000' PRIMPATH='/openvpn'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CRYPTOPATH="${HOSTPATH}/crypto"

perm_group "${HOSTPATH}" '-maxdepth 0'
perm_user "${CRYPTOPATH}"

docker run \
    --rm \
    --attach='STDOUT' \
    --attach='STDERR' \
    --entrypoint='/usr/bin/openvpn' \
    --volume="${CRYPTOPATH}:${PRIMPATH}/crypto" \
    --net=none \
    nfnty/arch-openvpn:latest \
    --genkey --secret /openvpn/crypto/ta.key
