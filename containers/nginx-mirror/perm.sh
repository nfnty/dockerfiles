#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"
source "${SCRIPTDIR}/../_misc/permissions.sh"

perm_user_ro "${CONFIGPATH}"
perm_user_rw "${LIBPATH}"
perm_user_rw "${LOGPATH}"
perm_user_rw "${RUNPATH}"

perm_custom "${PKGPATH}" '99999' '99999' 'u=rwX,g=rX,o=rX'
