#!/usr/bin/bash

BTRFSPATH='/var/lib/docker/btrfs/subvolumes'
SRVPATH='/srv/docker'
HOSTPATH="${SRVPATH}/${CNAME}"

DNSSERVER='172.17.42.1'

source "${SCRIPTDIR}/../../scripts/permissions.sh"
