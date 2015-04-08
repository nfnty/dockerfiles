#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

IPREFIX="${1}"
INAME="${2}"
ITAG="${3}"

DOCKERDIR="${SCRIPTDIR}/../images/${IPREFIX}-${INAME}/${ITAG}"

docker build --tag="nfnty/${IPREFIX}-${INAME}:${ITAG}" "${DOCKERDIR}"
