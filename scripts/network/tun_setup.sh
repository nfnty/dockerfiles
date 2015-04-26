#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

IFNAME="${1}"
IPADDR="${2}"

RETRIES=30
while [[ "${RETRIES}" -gt 0 ]]; do
    CPID="$(docker inspect --format='{{ .State.Pid }}' ${CNAME})"
    if [[ "${CPID}" != '0' ]]; then
        break
    fi
    sleep 0.1
    RETRIES=$((RETRIES - 1))
done

if [[ "${CPID}" == '<no value>' ]]; then
    echo "ERROR: Container ${CNAME} not found, and unknown to Docker."
    exit 1
elif [[ "${CPID}" -eq 0 ]]; then
    echo 'ERROR: Docker inspect returned invalid PID 0'
    exit 1
elif [[ "${CPID}" -lt 0 ]]; then
    echo 'ERROR: Negative integer!'
    exit 1
fi

ip netns exec "${CPID}" ip tuntap add "${IFNAME}" mode tun user "${UGID}" group "${UGID}"
ip netns exec "${CPID}" ip link set "${IFNAME}" up
ip netns exec "${CPID}" ip addr add "${IPADDR}" dev "${IFNAME}"
