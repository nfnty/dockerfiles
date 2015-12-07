FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV MONO_VERSION='4.2.1.102-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "mono=${MONO_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete
