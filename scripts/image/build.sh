#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

NAME="${1%:*}"
NAME="${NAME#*/}"
TAG="${1#*:}"

DOCKERPATH="${SCRIPTDIR}/../../images/${NAME}/${TAG}"

if [[ -d "${DOCKERPATH}/bootstrap" ]]; then
    cd "${DOCKERPATH}/bootstrap"
    sha512sum --check --strict "${NAME}-bootstrap.tar.xz.sha512sum"
fi

if [[ "${4:-}" == '--no-cache' ]]; then
    docker build --no-cache --tag="${1}" "${DOCKERPATH}"
else
    docker build --tag="${1}" "${DOCKERPATH}"
fi
