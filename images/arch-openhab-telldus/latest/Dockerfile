FROM nfnty/arch-openhab:latest
MAINTAINER nfnty <docker@nfnty.se>

USER root
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm telldus-core-git && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER ${UGNAME}
VOLUME ["/var/lib/telldus"]
ENTRYPOINT ["/usr/bin/bash", "-c", "/usr/bin/telldusd --nodaemon & exec /opt/openhab/start.sh"]
