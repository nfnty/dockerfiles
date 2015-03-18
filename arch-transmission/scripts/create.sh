#!/usr/bin/bash

set -e

CNAME='transmission'
UGID=100000
TORRENTPATH='/mnt/1/share/torrent'
CONFIGPATH='/srv/docker/transmission/config'

WTESTPATHS=(
    "$TORRENTPATH/completed"
    "$TORRENTPATH/downloading"
    "$TORRENTPATH/seeding"
    "$CONFIGPATH"
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
    --volume="$CONFIGPATH:/transmission/config" \
    --volume="$TORRENTPATH:/torrent" \
    --net=none \
    --name="$CNAME" \
    nfnty/arch-transmission
