FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880029' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_HEKA='0.10.0-6'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nfnty/heka=${VERSION_HEKA}" geoip-database-extra && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    chown --recursive contusr:contgrp /var/cache/hekad

USER contusr
VOLUME ["/var/cache/hekad"]
EXPOSE 4352/tcp
ENTRYPOINT ["/usr/bin/hekad", "-config=/etc/heka/conf.d/"]
