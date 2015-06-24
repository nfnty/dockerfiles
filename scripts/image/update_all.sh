#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

AGE='7200'

older() {
    if [[ "$( "${SCRIPTDIR}/older.py" "${1}" "${2}" )" == 'True' ]]; then
        return 0
    else
        return 1
    fi
}

update() {
    if older "${1}" "${AGE}"; then
        echo -e "\033[33mBuilding: ${1}\033[0m"
        "${SCRIPTDIR}/build.sh" "${1}"
        echo -e "\033[32mCompleted: ${1}\033[0m\n"
    else
        echo -e "\033[34mNot older than "${AGE}" seconds: ${1}\033[0m\n"
    fi
}

source "${SCRIPTDIR}/images.sh"

docker rmi $(docker images --filter='dangling=true' --quiet)
