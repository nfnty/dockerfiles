#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

BTRFSPATH="/var/lib/docker/btrfs/subvolumes"

CNAME='logstash'
UGID=130000
PRIMPATH="/logstash"

BASEPATH="/srv/docker/logstash"
CONFIGPATH="$BASEPATH/config"
DATAPATH="$BASEPATH/data"
SINCEDBPATH="$DATAPATH/sincedb"
ULOGDPATH="/var/log/ulogd"

TESTSCRIPT="$SCRIPTDIR/../../scripts/test_file.py"

set +o noglob
for testpath in "$CONFIGPATH/"*; do
    "$TESTSCRIPT" 'fr' "$UGID" "$testpath"
done
set -o noglob
"$TESTSCRIPT" 'drx' "$UGID" "$DATAPATH"
set +o noglob
for testpath in "$ULOGDPATH/"*; do
    "$TESTSCRIPT" 'fr' "$UGID" "$testpath"
done
set -o noglob
"$TESTSCRIPT" 'drwxUG' "$UGID" "$SINCEDBPATH"

docker create \
    --volume="$CONFIGPATH:$PRIMPATH/config:ro" \
    --volume="$DATAPATH:$PRIMPATH/data" \
    --volume="$ULOGDPATH:$PRIMPATH/host/ulogd:ro" \
    --net=none \
    --name="$CNAME" \
    nfnty/arch-logstash:latest

CID="$(docker inspect --format='{{.Id}}' "$CNAME")"

cd "$BTRFSPATH/$CID"
setfattr --name=user.pax.flags --value=em usr/lib/jvm/java-8-openjdk/jre/bin/java
