FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880034' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_RSYSLOG='8.40.0-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nfnty/rsyslog=${VERSION_RSYSLOG}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner=contusr --group=contgrp --mode=700 /var/log/rsyslog /run

USER contusr
VOLUME ["/var/log/rsyslog"]
ENTRYPOINT ["/usr/bin/rsyslogd", "-n", "-i", "/run/rsyslog.pid"]
