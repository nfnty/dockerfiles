#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

UGID=99999

BASEPATH='/srv/docker/makepkg'
PKGBUILDPATH="$BASEPATH/pkgbuilds"
PKGDEST="$BASEPATH/pkgdest"
LOGPATH="$BASEPATH/logs"

TESTSCRIPT="$SCRIPTDIR/../../scripts/test_file.py"

"$TESTSCRIPT" 'drx' "$UGID" "$PKGBUILDPATH"
"$TESTSCRIPT" 'drwxUG' "$UGID" "$PKGDEST"
"$TESTSCRIPT" 'drwxUG' "$UGID" "$LOGPATH"

