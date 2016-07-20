FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='190000' UGNAME='openvpn'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_OPENVPN='2.3.11-2'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "openvpn=${VERSION_OPENVPN}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner="${UGNAME}" --group=root --mode=770 \
        /var/lib/openvpn /var/log/openvpn /tmp

USER root
VOLUME ["/var/lib/openvpn"]
EXPOSE 1194/tcp 1194/udp
ENTRYPOINT [ \
    "/usr/bin/bash", "-c", \
    "/usr/bin/iptables --table nat --append POSTROUTING --out-interface eth0 --jump MASQUERADE && \
    exec /usr/bin/openvpn --config /etc/openvpn/server.conf" \
]
