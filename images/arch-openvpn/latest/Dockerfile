FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880019' && \
    groupadd --gid "${ugid}" openvpn && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false openvpn

ENV VERSION_OPENVPN='2.4.6-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "openvpn=${VERSION_OPENVPN}" nftables && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner=openvpn --group=root --mode=770 \
        /var/lib/openvpn /var/log/openvpn /tmp

USER root
VOLUME ["/var/lib/openvpn"]
EXPOSE 1194/tcp 1194/udp
ENTRYPOINT [ \
    "/usr/bin/bash", "-c", \
    "/usr/bin/iptables --table nat --append POSTROUTING --out-interface eth0 --jump MASQUERADE && \
    /usr/bin/ip6tables --table nat --append POSTROUTING --out-interface eth0 --jump MASQUERADE && \
    exec /usr/bin/openvpn --config /etc/openvpn/server.conf" \
]
