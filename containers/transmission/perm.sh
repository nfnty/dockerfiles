#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"
source "${SCRIPTDIR}/../_misc/permissions.sh"

perm_user_rw "${CONFIGPATH}"
perm_custom "${TORRENTPATH}" "${UGID}" '140000' 'u=rwX,g=rwXs,o=' '-type d'
perm_custom "${TORRENTPATH}" "${UGID}" '140000' 'u=rwX,g=rwX,o=' '-type f'
