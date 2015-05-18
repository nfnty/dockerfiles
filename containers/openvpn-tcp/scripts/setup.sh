#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='openvpn-tcp' UGID='190000' PRIMPATH='/openvpn'
MEMORY='2G' CPU_SHARES='512'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CRYPTOPATH="${HOSTPATH}/crypto"

perm_group "${HOSTPATH}" '-maxdepth 0'
perm_user "${CRYPTOPATH}"

docker run \
    --rm \
    --attach='STDOUT' \
    --attach='STDERR' \
    --read-only \
    --volume="${CRYPTOPATH}:${PRIMPATH}/crypto:rw" \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}_setup" \
    --hostname="${CNAME}_setup" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    --entrypoint='/usr/bin/openvpn' \
    nfnty/arch-openvpn:latest \
    --genkey --secret /openvpn/crypto/ta.key
