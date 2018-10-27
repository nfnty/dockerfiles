FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880010' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_TRANSMISSION='2.94-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "transmission-cli=${VERSION_TRANSMISSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner=contusr --group=contgrp --mode=700 \
        /var/lib/transmission /var/log/transmission

USER contusr
VOLUME ["/var/lib/transmission"]
EXPOSE 9091/tcp 51413/tcp 51413/udp
ENTRYPOINT ["/usr/bin/transmission-daemon", "--foreground", "--config-dir", "/var/lib/transmission"]
