FROM nfnty/arch-nginx:latest
MAINTAINER nfnty <docker@nfnty.se>

USER root

ENV VERSION_PHP='7.3.0-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "php=${VERSION_PHP}" "php-fpm=${VERSION_PHP}" python && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner=contusr --group=contgrp --mode=700 /run/php-fpm

USER contusr
ENTRYPOINT [ \
    "/opt/multiprocess.py", "--", \
    "/usr/bin/php-fpm --fpm-config /etc/php/php-fpm.conf", \
    "/usr/bin/nginx -g 'daemon off;'" \
]
