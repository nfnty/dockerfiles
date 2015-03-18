FROM nfnty/arch-mini

MAINTAINER "nfnty <docker@nfnty.se>"

ENV PATH="$PATH:/usr/lib/jvm/default/bin"

RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm jdk7-openjdk && \
    pacman --sync --noconfirm --clean --clean
