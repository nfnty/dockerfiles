FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880036' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_PROMETHEUS='1.7.1-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nfnty/prometheus=${VERSION_PROMETHEUS}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    chown --recursive contusr:contgrp /var/lib/prometheus

USER contusr
VOLUME ["/var/lib/prometheus"]
EXPOSE 9090/tcp
ENTRYPOINT [ \
    "/usr/bin/prometheus", \
    "-config.file=/etc/prometheus/config.yml", \
    "-storage.local.path=/var/lib/prometheus/data" \
]
