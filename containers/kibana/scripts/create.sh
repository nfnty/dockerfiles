#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

BTRFSPATH="/var/lib/docker/btrfs/subvolumes"

CNAME='kibana'
UGID=120000
PRIMPATH="/kibana"

BASEPATH="/srv/docker/kibana"
CONFIGPATH="$BASEPATH/config"

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

docker create \
    --volume="$CONFIGPATH:$PRIMPATH/config:ro" \
    --net=none \
    --name="$CNAME" \
    nfnty/arch-kibana

CID="$(docker inspect --format='{{.Id}}' "$CNAME")"

cd "$BTRFSPATH/$CID"
setfattr --name=user.pax.flags --value=em kibana/bin/node/bin/node
