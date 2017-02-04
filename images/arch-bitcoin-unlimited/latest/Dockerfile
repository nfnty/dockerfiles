FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880033' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_BITCOIN_UNLIMITED='1.0.0.1-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nfnty/bitcoin-unlimited=${VERSION_BITCOIN_UNLIMITED}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner=contusr --group=contgrp --mode=700 /var/lib/bitcoin

USER contusr
VOLUME ["/var/lib/bitcoin"]
EXPOSE 8333/tcp
ENTRYPOINT ["/usr/bin/bitcoind", "-conf=/etc/bitcoin/bitcoin.conf", "-datadir=/var/lib/bitcoin", "-printtoconsole"]
