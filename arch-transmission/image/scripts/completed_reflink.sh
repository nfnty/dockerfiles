#!/usr/bin/bash

set -e

cp --reflink=always --archive "$TR_TORRENT_DIR/$TR_TORRENT_NAME" "/torrent/completed/"
