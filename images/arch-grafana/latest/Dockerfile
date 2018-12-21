FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880021' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_GRAFANA='5.4.2-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nfnty/grafana=${VERSION_GRAFANA}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    chown --recursive contusr:contgrp /var/lib/grafana

USER contusr
VOLUME ["/var/lib/grafana"]
EXPOSE 3000/tcp
ENTRYPOINT [ \
    "/usr/bin/grafana-server", \
    "--homepath=/usr/share/grafana", \
    "--config=/etc/grafana/grafana.ini", \
    "cfg:default.log.mode=console" \
]
