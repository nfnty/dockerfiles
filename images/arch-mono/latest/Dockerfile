FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV VERSION_MONO='5.16.0.220-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "mono=${VERSION_MONO}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete
