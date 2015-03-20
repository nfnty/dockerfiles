#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

CNAME="${1}"
ENDSTATE="${2}"

systemctl stop "docker_${CNAME}"
docker rm "${CNAME}"
"${SCRIPTDIR}/../containers/${CNAME}/scripts/create.sh"
if [[ "$ENDSTATE" == 'on' ]]; then
    systemctl start "docker_${CNAME}"
fi
