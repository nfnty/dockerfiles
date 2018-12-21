FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880014' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_SAMBA='4.9.4-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "samba=${VERSION_SAMBA}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_bind_service=ep' /usr/bin/smbd && \
    chown --recursive contusr:contgrp /var/cache/samba /var/lib/samba /var/log/samba && \
    install --directory --owner=contusr --group=contgrp --mode=700 /run/samba

USER contusr
VOLUME ["/var/cache/samba", "/var/lib/samba"]
EXPOSE 139/tcp 445/tcp
ENTRYPOINT ["/usr/bin/smbd", "--foreground", "--option=pid directory=/run/samba"]
