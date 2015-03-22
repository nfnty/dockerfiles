FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

ENV PATH="$PATH:/usr/lib/jvm/default/bin"

ENV JAVA_VERSION="8.u40-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm jre8-openjdk-headless && \
    pacman --sync --noconfirm --clean --clean
