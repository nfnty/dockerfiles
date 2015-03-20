FROM scratch

MAINTAINER "nfnty <docker@nfnty.se>"

ADD bootstrap/arch-mini-bootstrap_2015-03-20.tar.xz /

ADD config/mirrorlist /etc/pacman.d/
ADD config/locale.conf config/pacman.conf /etc/
RUN chmod 664 /etc/pacman.d/mirrorlist /etc/locale.conf /etc/pacman.conf

RUN pacman-key --init && \
    pacman-key --populate archlinux

RUN ln --symbolic /usr/share/zoneinfo/UTC /etc/localtime
RUN localedef --inputfile=en_US --charmap=UTF-8 en_US.UTF-8 && \
    localedef --inputfile=en_DK --charmap=UTF-8 en_DK.UTF-8
