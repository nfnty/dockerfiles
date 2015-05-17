FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="0" UGNAME="root" PRIMPATH="/kea"

RUN install --directory --owner=root --group=root --mode=700 \
        "${PRIMPATH}/"{,config,crypto,data,cache}
VOLUME ["${PRIMPATH}/crypto", "${PRIMPATH}/data", "${PRIMPATH}/cache"]

ENV KEA_VERSION="0.9.1-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "kea=${KEA_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    rmdir /var/cache/kea && \
    ln --symbolic "${PRIMPATH}/cache" /var/cache/kea

USER root
EXPOSE 67
