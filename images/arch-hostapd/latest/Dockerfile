FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880027' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_HOSTAPD='2.7-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "hostapd=${VERSION_HOSTAPD}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_admin,cap_net_raw=ep' /usr/bin/hostapd

USER contusr
ENTRYPOINT ["/usr/bin/hostapd", "/etc/hostapd/hostapd.conf"]
