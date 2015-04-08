#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

CNAME="${1}"
ENDSTATE="${2}"

start_container() {
    if [[ "${ENDSTATE}" == 'on' ]]; then
        systemctl start "docker_${CNAME}"
    fi
}

revert_renaming_stage1() {
    docker inspect "${CNAME}_old2" &>/dev/null && \
        docker rename "${CNAME}_old2" "${CNAME}_old1"
}
revert_renaming_stage2() {
    docker inspect "${CNAME}_old1" &>/dev/null && \
        docker rename "${CNAME}_old1" "${CNAME}"
    docker inspect "${CNAME}_old2" &>/dev/null && \
        docker rename "${CNAME}_old2" "${CNAME}_old1"
}

docker inspect "${CNAME}_old2" &>/dev/null && \
    docker rm "${CNAME}_old2"

docker inspect "${CNAME}_old1" &>/dev/null && \
    docker rename "${CNAME}_old1" "${CNAME}_old2"

systemctl status "docker_${CNAME}" &>/dev/null && {
    systemctl stop "docker_${CNAME}" || {
        echo 'Failed to stop container!'
        revert_renaming_stage1
        start_container
        exit 1
    }
}

docker inspect "${CNAME}" &>/dev/null && \
    docker rename "${CNAME}" "${CNAME}_old1"

"${SCRIPTDIR}/../containers/${CNAME}/scripts/create.sh" || {
    echo 'Failed to create container!'
    revert_renaming_stage2
    start_container
    exit 1
}

start_container
