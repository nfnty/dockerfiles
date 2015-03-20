#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

CNAME="$1"
BRNAME="$2"
DROUTE="$3"
IFNAME="$4"
IPADDR="$5"
MACADDR="$6"

CPID="$(docker inspect --format='{{.State.Pid}}' $CNAME)"
while [[ ! "$CPID" -gt "0" ]]; do
    echo "Sleeping for 0.1s"
    sleep 0.1
    CPID="$(docker inspect --format='{{.State.Pid}}' $CNAME)"
done

mkdir --parents /run/netns
ln --symbolic "/proc/$CPID/ns/net" "/run/netns/$CPID"

ip link add "ve_$IFNAME" type veth peer name "vp_$IFNAME"
brctl addif "$BRNAME" "ve_$IFNAME"
ip link set "ve_$IFNAME" up

ip link set "vp_$IFNAME" netns "$CPID"
ip netns exec "$CPID" ip link set dev "vp_$IFNAME" name eth0
ip netns exec "$CPID" ip link set eth0 address "$MACADDR"
ip netns exec "$CPID" ip link set eth0 up
ip netns exec "$CPID" ip addr add "$IPADDR" dev eth0
ip netns exec "$CPID" ip route add default via "$DROUTE"
