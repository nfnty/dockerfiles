FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880039' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm nfnty/acoustid-index-git && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner=contusr --group=contgrp --mode=700 /var/lib/acoustid-index

USER contusr
VOLUME ["/var/lib/acoustid-index"]
EXPOSE 6080/tcp
ENTRYPOINT ["/usr/bin/fpi-server", "--directory", "/var/lib/acoustid-index", "--address", "::"]
