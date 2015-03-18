#!/usr/bin/bash

set -e

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

docker build --tag='nfnty/arch-java:jdk8-openjdk' "$SCRIPTDIR/../image/"
