#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CLONEPATH="${TMPDIR}/pkgbuilds"
GITURL='https://github.com/nfnty/pkgbuilds.git'
DB='nfnty'

git clone "${GITURL}" "${CLONEPATH}"
cd "${CLONEPATH}"
directories=$( find . -name 'PKGBUILD' -printf '%h\n' )
rm --recursive --force "${CLONEPATH}"
cd "${SCRIPTDIR}"

for directory in ${directories[@]}; do
    if [[ "${directory##*/}" == "${1}" ]]; then
        "${SCRIPTDIR}/create.sh" "${directory##*/}" --git "${GITURL}" --db "${DB}" --path "${directory}"
        docker start "builder_${directory##*/}"
        docker logs --follow "builder_${directory##*/}"
        break
    fi
done
