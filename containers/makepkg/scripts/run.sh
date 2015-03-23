#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

BASEPATH='/srv/docker/makepkg'
PKGBUILDPATH="$BASEPATH/pkgbuilds"
PKGDEST="$BASEPATH/pkgdest"
LOGPATH="$BASEPATH/logs"

docker run \
    --rm \
    --attach="STDOUT" \
    --attach="STDERR" \
    --volume="$PKGBUILDPATH:/makepkg/host/pkgbuild:ro" \
    --volume="$PKGDEST:/makepkg/pkgdest" \
    --volume="$LOGPATH:/makepkg/logs" \
    --net=bridge \
    nfnty/arch-makepkg:latest \
    $@
