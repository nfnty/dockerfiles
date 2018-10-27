FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880023' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_NTP='4.2.8.p12-2'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nfnty/ntp=${VERSION_NTP}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_ipc_lock,cap_net_bind_service,cap_sys_time=ep' /usr/bin/ntpd && \
    chown --recursive contusr:contgrp /var/lib/ntp

USER contusr
VOLUME ["/var/lib/ntp"]
EXPOSE 123/udp
ENTRYPOINT ["/usr/bin/ntpd", "--nofork", "--panicgate"]
