FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880046' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_DANTE='1.4.2-2'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "dante=${VERSION_DANTE}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER contusr
EXPOSE 1080/tcp 1080/udp
ENTRYPOINT ["/usr/bin/sockd"]
