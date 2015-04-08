#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

CNAME='transmission'
UGID=100000
PRIMPATH='/transmission'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
TORRENTPATH='/mnt/1/share/torrent'

perm_group "${HOSTPATH}" '-maxdepth 0'
perm_custom "${TORRENTPATH}" "${UGID}" '140000' 'u=rwX,g=rwX,o=' '-type f'
perm_custom "${TORRENTPATH}" "${UGID}" '140000' 'u=rwX,g=rwXs,o=' '-type d'
perm_user "${CONFIGPATH}"

docker create \
    --volume="${CONFIGPATH}:${PRIMPATH}/config" \
    --volume="${TORRENTPATH}:/torrent" \
    --net=none \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    nfnty/arch-transmission:latest
