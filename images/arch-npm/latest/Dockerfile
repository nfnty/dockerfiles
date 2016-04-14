FROM nfnty/arch-nodejs:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV VERSION_NPM='3.8.6-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "npm=${VERSION_NPM}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete
