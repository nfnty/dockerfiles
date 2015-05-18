#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME='nginx-proxy' UGID='160000' PRIMPATH='/nginx'
MEMORY='2G' CPU_SHARES='512'

source "${SCRIPTDIR}/../../scripts/variables.sh"

CONFIGPATH="${HOSTPATH}/config"
LIBPATH="${HOSTPATH}/lib"
CRYPTOPATH="${HOSTPATH}/crypto"
HTPASSWDPATH="${HOSTPATH}/htpasswd"

perm_root "${HOSTPATH}" '-maxdepth 0'
perm_root "${CONFIGPATH}"
perm_group "${LIBPATH}" '-maxdepth 0'
perm_user "${LIBPATH}" '-mindepth 1'
perm_root "${CRYPTOPATH}"
perm_group "${HTPASSWDPATH}"

docker create \
    --read-only \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${LIBPATH}:${PRIMPATH}/lib:rw" \
    --volume="${CRYPTOPATH}:${PRIMPATH}/crypto:ro" \
    --volume="${HTPASSWDPATH}:${PRIMPATH}/htpasswd:ro" \
    --net='none' \
    --dns="${DNSSERVER}" \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-nginx:latest
