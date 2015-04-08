FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm --needed base-devel git paxd && \
    pacman --sync --noconfirm --clean --clean
