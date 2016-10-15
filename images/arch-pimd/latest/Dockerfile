FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880030' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_PIMD='2.3.2-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nfnty/pimd=${VERSION_PIMD}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_admin,cap_net_raw=ep' /usr/bin/pimd && \
    rm /var/run && \
    install --directory --owner=contusr --group=contgrp --mode=700 /var/run

USER contusr
ENTRYPOINT ["/usr/bin/pimd", "--foreground", "--disable-vifs"]
