#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"
source "${SCRIPTDIR}/../_misc/permissions.sh"

perm_user_ro "${PATH_ETC}"
perm_user_rw "${PATH_LIB}" "-path ${PATH_LIB}/pkg -prune -or"
perm_custom "${PATH_LIB}/pkg" "${UGID}" "${UGID}" 'u=rwX,g=rX,o=rX'
perm_user_rw "${PATH_LOG}"
perm_custom "${PATH_PKGCACHE}" '0' '0' 'u=rwX,g=rX,o=rX'
perm_user_rw "${PATH_PKGBUILD}"
