FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="0" UGNAME="root" PRIMPATH="/hostapd"

RUN install --directory --owner=root --group=root --mode=500 \
        "${PRIMPATH}/"{,config}

ENV HOSTAPD_VERSION="2.4-2"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "hostapd=${HOSTAPD_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER root
ENTRYPOINT ["/usr/bin/hostapd", "/hostapd/config/hostapd.conf"]
