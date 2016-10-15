FROM nfnty/arch-openhab:latest
MAINTAINER nfnty <docker@nfnty.se>

USER root
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm nfnty/telldus-core-git python && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER contusr
VOLUME ["/var/lib/telldus"]
ENTRYPOINT ["/opt/multiprocess.py", "--", "/usr/bin/telldusd --nodaemon", "/opt/openhab/start.sh"]
