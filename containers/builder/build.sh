#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PATH_CLONE="${TMPDIR}/pkgbuilds"
GITURL='https://github.com/nfnty/pkgbuilds.git'
DB='nfnty'
PKGNAME="${1}"
CNAME="builder_${PKGNAME}"

git clone "${GITURL}" "${PATH_CLONE}"
cd "${PATH_CLONE}"
directories=$( find . -name 'PKGBUILD' -printf '%h\n' )
rm --recursive --force "${PATH_CLONE}"
cd "${SCRIPTDIR}"

for directory in ${directories[@]}; do
    package="${directory##*/}"
    if [[ "${package}" == "${PKGNAME}" ]]; then
        "${SCRIPTDIR}/create.sh" "${CNAME}" --git "${GITURL}" --db "${DB}" --path "${directory}"
        docker start "${CNAME}"
        docker logs --follow "${CNAME}"
        exit 0
    fi
done

echo "Failed to create builder for package: ${1}"
exit 1
