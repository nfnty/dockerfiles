FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='350000' UGNAME='influxdb'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_INFLUXDB='0.12.1-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nfnty/influxdb=${VERSION_INFLUXDB}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    chown --recursive "${UGNAME}:${UGNAME}" /var/lib/influxdb

USER ${UGNAME}
VOLUME ["/var/lib/influxdb"]
EXPOSE 8083/tcp 8086/tcp 8088/tcp 8091/tcp
ENTRYPOINT ["/usr/bin/influxd", "--config", "/etc/influxdb/config.toml"]
