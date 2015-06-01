#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CLONEPATH="${TMPDIR}/pkgbuilds"

git clone 'https://github.com/nfnty/pkgbuilds.git' "${CLONEPATH}"
cd "${CLONEPATH}"

for directory in $( find . -name 'PKGBUILD' -printf '%h\n' ); do
    "${SCRIPTDIR}/create.sh" "${directory##*/}" --git 'https://github.com/nfnty/pkgbuilds.git' --db nfnty --path "${directory}"
done

rm --recursive "${CLONEPATH}"
