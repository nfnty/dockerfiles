#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"
source "${SCRIPTDIR}/../_misc/permissions.sh"

perm_user_rw "${PATH_CACHE}" "( -path ${PATH_CACHE}/lck -or -path ${PATH_CACHE}/msg ) -prune -or"
perm_custom "${PATH_CACHE}/lck" "${UGID}" "${UGID}" 'u=rwX,g=rX,o=rX'
perm_custom "${PATH_CACHE}/msg" "${UGID}" "${UGID}" 'u=rwX,g=rX,o=rX'
perm_user_ro "${PATH_CONFIG}"
perm_user_rw "${PATH_LIB}"
perm_user_rw "${PATH_LIB}/private"
perm_user_rw "${PATH_LOG}"
perm_user_rw "${PATH_RUN}"
perm_custom "${PATH_SHARE1}" "${UGID}" "${UGID}" 'u=rwX,g=rwXs,o=' '-type d' "-and -not -path ${PATH_SHARE1}/torrent*"
perm_custom "${PATH_SHARE1}" "${UGID}" "${UGID}" 'u=rwX,g=rwX,o=' '-type f' "-and -not -path ${PATH_SHARE1}/torrent*"
