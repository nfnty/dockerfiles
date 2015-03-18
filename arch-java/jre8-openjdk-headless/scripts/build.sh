#!/usr/bin/bash

set -e

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

docker build --tag='nfnty/arch-java:jre8-openjdk-headless' "$SCRIPTDIR/../image/"
