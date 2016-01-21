FROM nfnty/arch-nginx:latest
MAINTAINER nfnty <docker@nfnty.se>

USER root

ENV VERSION_PHP='7.0.2-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "php=${VERSION_PHP}" "php-fpm=${VERSION_PHP}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 /run/php-fpm

USER ${UGNAME}
ENTRYPOINT [ \
    "/usr/bin/bash", "-c", \
    "/usr/bin/php-fpm --fpm-config /etc/php/php-fpm.conf && \
    exec /usr/bin/nginx -g 'daemon off;'" \
]
