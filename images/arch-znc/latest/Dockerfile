FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880044' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_ZNC='1.7.1-6'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "znc=${VERSION_ZNC}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner=contusr --group=contgrp --mode=700 /var/lib/znc

USER contusr
VOLUME ["/var/lib/znc"]
EXPOSE 6697/tcp 8080/tcp
ENTRYPOINT ["/usr/bin/znc", "--datadir=/var/lib/znc", "--foreground"]
