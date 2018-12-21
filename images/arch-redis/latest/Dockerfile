FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880038' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_REDIS='5.0.3-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "redis=${VERSION_REDIS}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner=contusr --group=contgrp --mode=700 /var/lib/redis

USER contusr
VOLUME ["/var/lib/redis"]
EXPOSE 6379/tcp
ENTRYPOINT ["/usr/bin/redis-server", "/etc/redis.conf"]
