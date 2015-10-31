#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"
source "${SCRIPTDIR}/../_misc/permissions.sh"

perm_root_rw "${ARCHIVEPATH}"
perm_root_rw "${GNUPGPATH}"
perm_custom "${PKGCACHEPATH}" '0' '0' 'u=rwX,g=rX,o=rX'
perm_root_rw "${TMPPATH}"
