FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV PYTHON2_VERSION='2.7.11-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "python2=${PYTHON2_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete
