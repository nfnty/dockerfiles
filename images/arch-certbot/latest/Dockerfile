FROM nfnty/arch-python2:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880002' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_CERTBOT='0.29.1-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "certbot=${VERSION_CERTBOT}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    chown --recursive contusr:contgrp /var/lib/letsencrypt /var/log/letsencrypt

USER contusr
VOLUME ["/var/lib/letsencrypt", "/var/log/letsencrypt"]
ENTRYPOINT ["/usr/bin/certbot"]
