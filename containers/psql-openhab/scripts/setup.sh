#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='psql-openhab' UGID='180000' PRIMPATH='/postgres'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CRYPTOPATH="${HOSTPATH}/crypto"
DATAPATH="${HOSTPATH}/data"

perm_group "${HOSTPATH}" '-maxdepth 0'
perm_user "${CRYPTOPATH}"
perm_user "${DATAPATH}"

docker run \
    --rm \
    --tty \
    --interactive \
    --entrypoint='/usr/bin/bash' \
    --volume="${CRYPTOPATH}:${PRIMPATH}/crypto" \
    --volume="${DATAPATH}:${PRIMPATH}/data" \
    --net=none \
    --dns="${DNSSERVER}" \
    nfnty/arch-postgresql:latest
