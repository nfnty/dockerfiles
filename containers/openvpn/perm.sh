#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"
source "${SCRIPTDIR}/../_misc/permissions.sh"

perm_ur_ro "${CONFIGPATH}"
perm_ur_rw "${LIBPATH}"
perm_ur_rw "${LOGPATH}"
perm_ur_rw "${TMPPATH}"
perm_custom "${TUNPATH}" '0' '0' 'u=rw,g=rw,o=rw'
