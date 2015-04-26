#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

# CNAME="${1}"

CID="$(docker inspect --format='{{.Id}}' "${CNAME}")"

systemctl stop "docker-${CID}.scope"
