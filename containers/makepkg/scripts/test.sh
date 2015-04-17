#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTDIR}/variables.sh"

perm_group "${HOSTPATH}" '-maxdepth 0'
perm_group "${PKGBUILDPATH}"
perm_group "${CONFIGPATH}"
perm_user "${SRCDEST}"
perm_user "${LOGPATH}"
perm_group "${HOSTPATH}/crypto" '-maxdepth 0'
perm_user "${GNUPGHOME}"
perm_custom "${PKGDEST}" "${UGID}" "${UGID}" 'u=rwX,g=rX,o=rX'
perm_root "${PKGCACHE}"
