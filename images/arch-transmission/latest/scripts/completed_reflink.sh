#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

cp --reflink=always --archive "${TR_TORRENT_DIR}/${TR_TORRENT_NAME}" "/torrent/completed/"
