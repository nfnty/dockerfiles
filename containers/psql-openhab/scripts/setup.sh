#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='psql-openhab' UGID='180000' PRIMPATH='/postgres'
MEMORY='2G' CPU_SHARES='1024'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CRYPTOPATH="${HOSTPATH}/crypto"
DATAPATH="${HOSTPATH}/data"

perm_user_rw "${CRYPTOPATH}"
perm_user_rw "${DATAPATH}"

docker run \
    --rm \
    --tty \
    --interactive \
    --read-only \
    --volume="${CRYPTOPATH}:${PRIMPATH}/crypto:rw" \
    --volume="${DATAPATH}:${PRIMPATH}/data:rw" \
    --cap-drop 'ALL' \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}_setup" \
    --hostname="${CNAME}_setup" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    --entrypoint='/usr/bin/bash' \
    nfnty/arch-postgresql:latest
