#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

BTRFSPATH="/var/lib/docker/btrfs/subvolumes"

CNAME='kibana'
UGID=120000
PRIMPATH="/kibana"

BASEPATH="/srv/docker/kibana"
CONFIGPATH="$BASEPATH/config"

TESTSCRIPT="$SCRIPTDIR/../../scripts/test_file.py"

"$TESTSCRIPT" 'drx' "$UGID" "$CONFIGPATH"
"$TESTSCRIPT" 'fr' "$UGID" "$CONFIGPATH/kibana.yml"

docker create \
    --volume="$CONFIGPATH:$PRIMPATH/config:ro" \
    --net=none \
    --name="$CNAME" \
    nfnty/arch-kibana

CID="$(docker inspect --format='{{.Id}}' "$CNAME")"

cd "$BTRFSPATH/$CID"
setfattr --name=user.pax.flags --value=em kibana/bin/node/bin/node
