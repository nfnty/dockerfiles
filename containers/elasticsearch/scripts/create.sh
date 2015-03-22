#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

BTRFSPATH="/var/lib/docker/btrfs/subvolumes"

CNAME='elasticsearch'
UGID=110000
PRIMPATH="/elasticsearch"

BASEPATH="/srv/docker/elasticsearch"
CONFIGPATH="$BASEPATH/config"
DATAPATH="$BASEPATH/data"
LOGPATH="$BASEPATH/logs"

TESTSCRIPT="$SCRIPTDIR/../../scripts/test_file.py"

"$TESTSCRIPT" 'drwxUG' "$UGID" "$LOGPATH"
"$TESTSCRIPT" 'drwxUG' "$UGID" "$DATAPATH"
"$TESTSCRIPT" 'drx' "$UGID" "$CONFIGPATH"
"$TESTSCRIPT" 'fr' "$UGID" "$CONFIGPATH/elasticsearch.yml"
"$TESTSCRIPT" 'fr' "$UGID" "$CONFIGPATH/logging.yml"

docker create \
    --volume="$CONFIGPATH:$PRIMPATH/config:ro" \
    --volume="$DATAPATH:$PRIMPATH/data" \
    --volume="$LOGPATH:$PRIMPATH/logs" \
    --net=none \
    --name="$CNAME" \
    nfnty/arch-elasticsearch:latest

CID="$(docker inspect --format='{{.Id}}' "$CNAME")"

cd "$BTRFSPATH/$CID"
setfattr --name=user.pax.flags --value=em usr/lib/jvm/java-8-openjdk/jre/bin/java
