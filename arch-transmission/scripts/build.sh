#!/usr/bin/bash

set -e

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

docker build --tag='nfnty/arch-transmission' "$SCRIPTDIR/../image/"
