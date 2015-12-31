#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"
source "${SCRIPTDIR}/../_misc/permissions.sh"

perm_ur_ro "${PATH_ETC}"
perm_ur_rw "${PATH_LIB}"
perm_ur_rw "${PATH_LOG}"
perm_ur_rw "${PATH_TMP}"
perm_custom "${PATH_TUN}" '0' '0' 'u=rw,g=rw,o=rw'
