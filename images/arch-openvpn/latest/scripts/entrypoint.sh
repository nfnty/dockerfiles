#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

/usr/bin/iptables --table nat --append POSTROUTING --out-interface eth0 --jump MASQUERADE

exec /usr/bin/openvpn --config /openvpn/config/server.conf
