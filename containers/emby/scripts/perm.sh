#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"
source "${SCRIPTDIR}/../../scripts/permissions.sh"

perm_user_rw "${LIBPATH}"
perm_custom "${SHARE1}" '140000' '140000' 'u=rwX,g=rwXs,o=' '-type d' "-and -not -path ${SHARE1}/torrent*"
perm_custom "${SHARE1}" '140000' '140000' 'u=rwX,g=rwX,o=' '-type f' "-and -not -path ${SHARE1}/torrent*"
perm_user_rw "${TMPPATH}"
