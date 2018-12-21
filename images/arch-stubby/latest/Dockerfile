FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880050' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_STUBBY='0.2.3-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "stubby=${VERSION_STUBBY}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap \
        'cap_net_bind_service=eip' /usr/bin/tini \
        'cap_net_bind_service=ei' /usr/bin/stubby

USER contusr
EXPOSE 53/tcp 53/udp
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/bin/stubby"]
