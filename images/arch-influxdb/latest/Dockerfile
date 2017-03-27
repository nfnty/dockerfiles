FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880035' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_INFLUXDB='1.2.2-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nfnty/influxdb=${VERSION_INFLUXDB}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    chown --recursive contusr:contgrp /var/lib/influxdb

USER contusr
VOLUME ["/var/lib/influxdb"]
EXPOSE 8083/tcp 8086/tcp 8088/tcp 8091/tcp
ENTRYPOINT ["/usr/bin/influxd", "--config", "/etc/influxdb/config.toml"]
