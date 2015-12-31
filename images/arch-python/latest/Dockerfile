FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV PYTHON_VERSION='3.5.1-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "python=${PYTHON_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete
