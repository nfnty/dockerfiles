#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

CNAME='nginx-mirror' UGID='160000' PRIMPATH='/nginx'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
PKGPATH='/mnt/2/docker/makepkg/pkgdest'

perm_root "${HOSTPATH}" '-maxdepth 0'
perm_root "${CONFIGPATH}"
perm_custom "${PKGPATH}" '99999' '99999' 'u=rwX,g=rX,o=rX'

docker create \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${PKGPATH}:${PRIMPATH}/data/root/archlinux/nfnty/os/x86_64:ro" \
    --net=none \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    nfnty/arch-nginx:latest
