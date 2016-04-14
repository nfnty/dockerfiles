FROM nfnty/arch-nginx-php:latest
MAINTAINER nfnty <docker@nfnty.se>

USER root

ENV VERSION_OWNCLOUD='9.0.1-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "owncloud=${VERSION_OWNCLOUD}" php-apcu php-pgsql && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    rm /usr/share/webapps/owncloud/config && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 /usr/share/webapps/owncloud/{config,data} && \
    chown --recursive "${UGNAME}:${UGNAME}" /usr/share/webapps/owncloud/apps

USER ${UGNAME}
VOLUME ["/usr/share/webapps/owncloud/apps", "/usr/share/webapps/owncloud/config", "/usr/share/webapps/owncloud/data"]
