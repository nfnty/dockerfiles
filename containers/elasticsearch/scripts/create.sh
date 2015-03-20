#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

BTRFSPATH="/var/lib/docker/btrfs/subvolumes"

CNAME='elasticsearch'
UGID=110000
PRIMPATH="/elasticsearch"

BASEPATH="/srv/docker/elasticsearch"
CONFIGPATH="$BASEPATH/config"
DATAPATH="$BASEPATH/data"
LOGPATH="$BASEPATH/logs"

RTESTPATHS=(
    "$CONFIGPATH"
)

for testpath in ${RTESTPATHS[@]}; do
    if ! sudo --user="#$UGID" test -r "$testpath"; then
        echo 'Read denied!'
        echo "UGID: $UGID"
        echo "Path: $testpath"
        exit 1
    elif sudo --user="#$UGID" test -w "$testpath"; then
        echo 'Write allowed!'
        echo "UGID: $UGID"
        echo "Path: $testpath"
        exit 1
    elif ! sudo --user="#$UGID" test -x "$testpath"; then
        echo 'Execute denied!'
        echo "UGID: $UGID"
        echo "Path: $testpath"
        exit 1
    fi
done

WTESTPATHS=(
    "$LOGPATH"
    "$DATAPATH"
)

for testpath in ${WTESTPATHS[@]}; do
    if ! sudo --user="#$UGID" test -r "$testpath"; then
        echo 'Read denied!'
        echo "UGID: $UGID"
        echo "Path: $testpath"
        exit 1
    elif ! sudo --user="#$UGID" test -w "$testpath"; then
        echo 'Write denied!'
        echo "UGID: $UGID"
        echo "Path: $testpath"
        exit 1
    elif ! sudo --user="#$UGID" test -x "$testpath"; then
        echo 'Execute denied!'
        echo "UGID: $UGID"
        echo "Path: $testpath"
        exit 1
    fi
done

docker create \
    --volume="$CONFIGPATH:$PRIMPATH/config:ro" \
    --volume="$DATAPATH:$PRIMPATH/data" \
    --volume="$LOGPATH:$PRIMPATH/logs" \
    --net=none \
    --name="$CNAME" \
    nfnty/arch-elasticsearch

CID="$(docker inspect --format='{{.Id}}' "$CNAME")"

cd "$BTRFSPATH/$CID"
setfattr --name=user.pax.flags --value=em usr/lib/jvm/java-8-openjdk/jre/bin/java
