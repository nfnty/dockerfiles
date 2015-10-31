#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"
source "${SCRIPTDIR}/../_misc/permissions.sh"

perm_user_ro "${MAKEPKGCONF}"
perm_user_rw "${LIBPATH}" "-path ${LIBPATH}/pkg -prune -or"
perm_custom "${LIBPATH}/pkg" "${UGID}" "${UGID}" 'u=rwX,g=rX,o=rX'
perm_user_rw "${LOGPATH}"
perm_custom "${PKGCACHEPATH}" '0' '0' 'u=rwX,g=rX,o=rX'
perm_user_rw "${PKGBUILDPATH}"
perm_user_rw "${TMPPATH}"
