#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"
source "${SCRIPTDIR}/../_misc/permissions.sh"

perm_user_rw "${PATH_APPS}"
perm_user_rw "${PATH_DATA}"
perm_user_rw "${PATH_CONFIG}"
perm_user_ro "${PATH_ETC_NGINX}"
perm_user_ro "${PATH_ETC_PHP}"
perm_user_rw "${PATH_LIB_NGINX}"
perm_user_rw "${PATH_LOG_NGINX}"
perm_user_rw "${PATH_RUN_NGINX}"
perm_user_rw "${PATH_RUN_PHP}"
perm_user_rw "${PATH_TMP}"
