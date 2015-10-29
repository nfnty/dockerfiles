FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm --needed base-devel git && \
    find /var/cache/pacman/pkg -mindepth 1 -delete
