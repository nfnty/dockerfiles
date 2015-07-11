#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

FULLNAME="${1}"
NAME="${FULLNAME%:*}"
NAME="${NAME#*/}"
TAG="${FULLNAME#*:}"
OPTS=${@:2}

DOCKERPATH="${SCRIPTDIR}/../../images/${NAME}/${TAG}"

if [[ -d "${DOCKERPATH}/bootstrap" ]]; then
    cd "${DOCKERPATH}/bootstrap"
    sha512sum --check --strict "${NAME}-bootstrap.tar.xz.sha512sum"
fi

docker build ${OPTS} --tag="${FULLNAME}" "${DOCKERPATH}"
