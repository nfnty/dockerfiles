FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880040' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_CLAMAV='0.99.2-7'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "clamav=${VERSION_CLAMAV}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    chown --recursive contusr:contgrp /var/lib/clamav

USER contusr
VOLUME ["/var/lib/clamav"]
EXPOSE 3310/tcp
ENTRYPOINT ["/usr/bin/clamd"]
