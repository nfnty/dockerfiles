FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880041' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_RSPAMD='1.8.3-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nfnty/rspamd=${VERSION_RSPAMD}" file && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner=contusr --group=contgrp --mode=700 /var/lib/rspamd

USER contusr
VOLUME ["/var/lib/rspamd"]
EXPOSE 11333/tcp 11334/tcp
ENTRYPOINT ["/usr/bin/rspamd", "--config=/etc/rspamd/rspamd.conf", "--no-fork"]
