#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"
source "${SCRIPTDIR}/../_misc/permissions.sh"

perm_user_ro "${PATH_CONFIG}"
perm_user_rw "${PATH_LIB}"
perm_user_rw "${PATH_LOG}"
perm_user_rw "${PATH_TMP}"
perm_custom "${PATH_ULOGD}" '0' '0' 'u=rwX,g=rX,o=rX'
