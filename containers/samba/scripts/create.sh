#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

CNAME='samba'
UGID=140000
PRIMPATH='/samba'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
DATAPATH="${HOSTPATH}/data"
SHARE1='/mnt/1/share'

perm_root "${HOSTPATH}" '-maxdepth 0'
perm_root "${DATAPATH}"
perm_root "${CONFIGPATH}"
perm_custom "${SHARE1}" "${UGID}" "${UGID}" 'u=rwX,g=rwXs,o=rX' '-maxdepth 0'
perm_custom "${SHARE1}" "${UGID}" "${UGID}" 'u=rwX,g=rwX,o=' '-mindepth 1 -type f' "-and -not -path ${SHARE1}/torrent*"
perm_custom "${SHARE1}" "${UGID}" "${UGID}" 'u=rwX,g=rwXs,o=' '-mindepth 1 -type d' "-and -not -path ${SHARE1}/torrent*"

docker create \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${DATAPATH}:${PRIMPATH}/data" \
    --volume="${SHARE1}:/share/1" \
    --net=none \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    nfnty/arch-samba:latest
