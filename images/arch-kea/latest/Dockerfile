FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880026' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_KEA='1.2.0-1' KEA_PIDFILE_DIR='/run/kea' KEA_LOGGER_DESTINATION='syslog'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nfnty/kea=${VERSION_KEA}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap \
        'cap_net_bind_service,cap_net_raw=ep' /usr/bin/kea-dhcp4 \
        'cap_net_bind_service,cap_net_raw=ep' /usr/bin/kea-dhcp6 && \
    chown --recursive contusr:contgrp /var/lib/kea /var/log/kea && \
    install --directory --owner=contusr --group=contgrp --mode=700 /run/kea

USER contusr
VOLUME ["/var/lib/kea"]
ENTRYPOINT ["/usr/bin/kea-dhcp4", "-c", "/etc/kea/kea.conf"]
