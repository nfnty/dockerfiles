FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

ENV PATH="${PATH}:/usr/lib/jvm/default/bin"

ENV JAVA_VERSION="7.u79_2.5.5-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "jre7-openjdk=${JAVA_VERSION}" && \
    pacman --sync --noconfirm --clean --clean
