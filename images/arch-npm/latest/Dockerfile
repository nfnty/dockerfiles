FROM nfnty/arch-nodejs:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV NPM_VERSION='3.3.12-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "npm=${NPM_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete
