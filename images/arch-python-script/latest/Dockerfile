FROM nfnty/arch-python:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880048' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm python-requests python-simplejson && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER contusr
ENTRYPOINT ["/usr/bin/false"]
