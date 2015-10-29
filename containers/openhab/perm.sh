#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"
source "${SCRIPTDIR}/../_misc/permissions.sh"

perm_user_ro "${ADDONPATH}"
perm_user_ro "${CONFIGPATH_JETTY}"
perm_user_ro "${CONFIGPATH_OPENHAB}"
perm_user_ro "${CONFIGPATH_TELLDUS}"
perm_user_rw "${LIBPATH_OPENHAB}"
perm_user_rw "${LIBPATH_TELLDUS}"
perm_user_rw "${LOGPATH}"
perm_user_rw "${TMPPATH}"
perm_user_rw "${WEBAPPSPATH}"
