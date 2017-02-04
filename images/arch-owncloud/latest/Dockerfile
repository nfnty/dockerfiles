FROM nfnty/arch-nginx-php:latest
MAINTAINER nfnty <docker@nfnty.se>

USER root

ENV VERSION_OWNCLOUD='9.1.3-2'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "owncloud=${VERSION_OWNCLOUD}" php-apcu php-pgsql && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    rm /usr/share/webapps/owncloud/config && \
    install --directory --owner=contusr --group=contgrp --mode=700 /usr/share/webapps/owncloud/{config,data} && \
    chown --recursive contusr:contgrp /usr/share/webapps/owncloud/apps

USER contusr
VOLUME ["/usr/share/webapps/owncloud/apps", "/usr/share/webapps/owncloud/config", "/usr/share/webapps/owncloud/data"]
