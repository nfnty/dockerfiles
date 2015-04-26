#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

# CNAME="${1}"
# BRNAME="${2}"
# DROUTE="${3}"
# IFNAME="${4}"
# IPADDR="${5}"
# MACADDR="${6}"

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

mkdir --parents /run/netns
ln --symbolic "/proc/${CPID}/ns/net" "/run/netns/${CPID}"

ip link add "ve_${IFNAME}" type veth peer name "vp_${IFNAME}"
brctl addif "${BRNAME}" "ve_${IFNAME}"
ip link set "ve_${IFNAME}" up

ip link set "vp_${IFNAME}" netns "${CPID}"
ip netns exec "${CPID}" ip link set dev "vp_${IFNAME}" name eth0
ip netns exec "${CPID}" ip link set eth0 address "${MACADDR}"
ip netns exec "${CPID}" ip link set eth0 up
ip netns exec "${CPID}" ip addr add "${IPADDR}" dev eth0
ip netns exec "${CPID}" ip route add default via "${DROUTE}"
