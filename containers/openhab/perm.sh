#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"
source "${SCRIPTDIR}/../_misc/permissions.sh"

perm_user_ro "${PATH_ADDONS}"
perm_user_ro "${PATH_CONFIG}"
perm_user_ro "${PATH_ETC_OPENHAB}"
perm_user_ro "${PATH_ETC_TELLDUS}"
perm_user_rw "${PATH_LIB_OPENHAB}"
perm_user_rw "${PATH_LIB_TELLDUS}"
perm_user_rw "${PATH_LOG}"
perm_user_rw "${PATH_TMP}"
perm_user_rw "${PATH_WEBAPPS}"
