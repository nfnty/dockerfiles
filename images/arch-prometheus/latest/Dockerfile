FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='360000' UGNAME='prometheus'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_PROMETHEUS='0.18.0-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "prometheus=${VERSION_PROMETHEUS}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    chown --recursive "${UGNAME}:${UGNAME}" /var/lib/prometheus

USER ${UGNAME}
VOLUME ["/var/lib/prometheus"]
EXPOSE 9090/tcp
ENTRYPOINT [ \
    "/usr/bin/prometheus", \
    "-config.file=/etc/prometheus/config.yml", \
    "-storage.local.path=/var/lib/prometheus/data" \
]
