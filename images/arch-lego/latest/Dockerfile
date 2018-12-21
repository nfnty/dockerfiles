FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880003' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_LEGO='1.2.1-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nfnty/lego=${VERSION_LEGO}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner=contusr --group=contgrp --mode=700 /var/lib/letsencrypt

USER contusr
VOLUME ["/var/lib/letsencrypt"]
ENTRYPOINT ["/usr/bin/lego", "--accept-tos", "--path=/var/lib/letsencrypt"]
