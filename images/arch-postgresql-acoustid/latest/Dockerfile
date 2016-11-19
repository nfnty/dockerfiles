FROM nfnty/arch-postgresql:latest
MAINTAINER nfnty <docker@nfnty.se>

USER root

RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm nfnty/pg_acoustid-git && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER postgres
