FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV VERSION_JAVA='8.u192-1' PATH="${PATH}:/usr/lib/jvm/default/bin"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "jre8-openjdk-headless=${VERSION_JAVA}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete
