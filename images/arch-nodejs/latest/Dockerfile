FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV VERSION_NODEJS='11.5.0-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nodejs=${VERSION_NODEJS}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete
