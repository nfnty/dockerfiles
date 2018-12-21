FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880024' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_POWERDNS_RECURSOR='4.1.8-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "powerdns-recursor=${VERSION_POWERDNS_RECURSOR}" lua-luajson && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_bind_service=ep' /usr/bin/pdns_recursor

USER contusr
EXPOSE 53/tcp 53/udp
ENTRYPOINT ["/usr/bin/pdns_recursor"]
