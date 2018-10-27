FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880042' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_RADVD='2.17-2'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "radvd=${VERSION_RADVD}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_raw=ep' /usr/bin/radvd

USER contusr
ENTRYPOINT ["/usr/bin/radvd", "--nodaemon", "--logmethod=stderr"]
