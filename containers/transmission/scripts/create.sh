#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

CNAME='transmission'
UGID=100000
TORRENTPATH='/mnt/1/share/torrent'
CONFIGPATH='/srv/docker/transmission/config'

TESTSCRIPT="$SCRIPTDIR/../../scripts/test_file.py"

"$TESTSCRIPT" 'drwxgU' "$UGID" "$TORRENTPATH/completed"
"$TESTSCRIPT" 'drwxgU' "$UGID" "$TORRENTPATH/downloading"
"$TESTSCRIPT" 'drwxgU' "$UGID" "$TORRENTPATH/seeding"
"$TESTSCRIPT" 'drwxUG' "$UGID" "$CONFIGPATH"

docker create \
    --volume="$CONFIGPATH:/transmission/config" \
    --volume="$TORRENTPATH:/torrent" \
    --net=none \
    --name="$CNAME" \
    nfnty/arch-transmission
