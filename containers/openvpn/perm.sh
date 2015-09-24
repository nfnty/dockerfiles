#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"
source "${SCRIPTDIR}/../_misc/permissions.sh"

perm_root_ro "${CONFIGPATH}"
perm_root_ro "${CRYPTOPATH}"
perm_ur_rw "${DATAPATH}"
perm_ur_ro "${SCRIPTSPATH}"
perm_ur_rw "${TMPPATH}"
perm_ur_rw "${TUNPATH}"
