FROM nfnty/arch-mini:latest

MAINTAINER nfnty <docker@nfnty.se>

ENV MONO_VERSION="4.0.4.1-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "mono=${MONO_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setfattr --name=user.pax.flags --value=em /usr/bin/mono-sgen && \
    cert-sync /etc/ssl/certs/ca-certificates.crt
