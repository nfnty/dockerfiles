#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"
source "${SCRIPTDIR}/../_misc/permissions.sh"

perm_user_rw "${CACHEPATH}" '' "-and -not -path ${CACHEPATH}/lck* -and -not -path ${CACHEPATH}/msg*"
perm_custom "${CACHEPATH}/lck" "${UGID}" "${UGID}" 'u=rwX,g=rX,o=rX'
perm_custom "${CACHEPATH}/msg" "${UGID}" "${UGID}" 'u=rwX,g=rX,o=rX'
perm_user_ro "${CONFIGPATH}"
perm_user_rw "${LIBPATH}"
perm_user_rw "${LIBPATH}/private"
perm_user_rw "${LOGPATH}"
perm_user_rw "${RUNPATH}"
perm_custom "${SHARE1}" "${UGID}" "${UGID}" 'u=rwX,g=rwXs,o=' '-type d' "-and -not -path ${SHARE1}/torrent*"
perm_custom "${SHARE1}" "${UGID}" "${UGID}" 'u=rwX,g=rwX,o=' '-type f' "-and -not -path ${SHARE1}/torrent*"
