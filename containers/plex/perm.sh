#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"
source "${SCRIPTDIR}/../_misc/permissions.sh"

perm_user_rw "${PATH_LIB}"
perm_user_rw "${PATH_TMP}"

perm_custom "${PATH_SHARE1}" '140000' '140000' 'u=rwX,g=rwXs,o=' "-path ${PATH_SHARE1}/torrent -prune -or -type d"
perm_custom "${PATH_SHARE1}" '140000' '140000' 'u=rwX,g=rwX,o=' "-path ${PATH_SHARE1}/torrent -prune -or -type f"
