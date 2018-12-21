FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880043' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false --home-dir /var/lib/parity/home contusr

ENV VERSION_PARITY='2.1.10-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "parity=${VERSION_PARITY}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner=contusr --group=contgrp --mode=700 /var/lib/parity/home

USER contusr
VOLUME ["/var/lib/parity"]
EXPOSE  8080/tcp 8180/tcp 8545/tcp 30303/tcp 30303/udp
ENTRYPOINT [ \
    "/usr/bin/parity", \
    "--db-path", "/var/lib/parity/db", \
    "--keys-path", "/var/lib/parity/keys", \
    "--ui-path", "/var/lib/parity/signer", \
    "--ipc-path", "/var/lib/parity/ipc" \
]
