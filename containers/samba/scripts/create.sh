#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

CNAME='samba'
UGID=140000

BASEPATH='/srv/docker/samba'
CONFIGPATH="$BASEPATH/config"
DATAPATH="$BASEPATH/data"
SHARE1='/mnt/1/share'

TESTSCRIPT="$SCRIPTDIR/../../scripts/test_file.py"

"$TESTSCRIPT" 'fr' "$UGID" "$CONFIGPATH/smb.conf"
"$TESTSCRIPT" 'drwxUG' '0' "$DATAPATH"
"$TESTSCRIPT" 'drwxUGg' "$UGID" "$SHARE1"

docker create \
    --volume="$CONFIGPATH:/samba/config:ro" \
    --volume="$DATAPATH:/samba/data" \
    --volume="$SHARE1:/share/1" \
    --net=none \
    --name="$CNAME" \
    nfnty/arch-samba:latest
