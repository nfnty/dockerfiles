FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV VERSION_PYTHON2='2.7.15-2'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "python2=${VERSION_PYTHON2}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete
