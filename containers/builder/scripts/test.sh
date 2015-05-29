#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTDIR}/variables.sh"

perm_user_ro "${CONFIGPATH}"
perm_user_rw "${GNUPGHOME}"
perm_user_rw "${LOGPATH}"
perm_user_rw "${SRCDEST}"
perm_user_ro "${PKGBUILDPATH}"
perm_root_rw "${PKGCACHE}"
perm_custom "${PKGDEST}" "${UGID}" "${UGID}" 'u=rwX,g=rX,o=rX'
