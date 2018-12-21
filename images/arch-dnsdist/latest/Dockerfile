FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880045' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_DNSDIST='1.3.3-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "dnsdist=${VERSION_DNSDIST}" lua-luajson && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_bind_service=ep' /usr/bin/dnsdist

USER contusr
EXPOSE 53/tcp 53/udp
ENTRYPOINT ["/usr/bin/dnsdist", "--supervised", "--config", "/etc/dnsdist/config.lua"]
