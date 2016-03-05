FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='360000' UGNAME='grafana'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_GRAFANA='2.6.0-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm grafana-git && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    chown --recursive "${UGNAME}:${UGNAME}" /var/lib/grafana

USER ${UGNAME}
VOLUME ["/var/lib/grafana"]
EXPOSE 3000/tcp
ENTRYPOINT [ \
    "/usr/bin/grafana-server", \
    "--homepath=/usr/share/grafana", \
    "--config=/etc/grafana/grafana.ini", \
    "cfg:default.log.mode=console" \
]
