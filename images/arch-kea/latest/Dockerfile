FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880026' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_KEA='1.4.0.P1-4' KEA_PIDFILE_DIR='/run/kea' KEA_LOGGER_DESTINATION='stderr'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "kea=${VERSION_KEA}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap \
        'cap_net_bind_service,cap_net_raw=ep' /usr/bin/kea-dhcp4 \
        'cap_net_bind_service,cap_net_raw=ep' /usr/bin/kea-dhcp6 && \
    install --directory --owner=contusr --group=contgrp --mode=700 \
        /var/kea /var/log/kea /run/kea

USER contusr
VOLUME ["/var/kea"]
ENTRYPOINT ["/usr/bin/kea-dhcp4", "-c", "/etc/kea/kea.conf"]
