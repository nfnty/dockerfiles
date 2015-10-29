FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="100000" UGNAME="transmission"
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV TRANSMISSION_VERSION="2.84-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "transmission-cli=${TRANSMISSION_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        /var/lib/transmission /var/log/transmission
VOLUME ["/var/lib/transmission", "/var/log/transmission"]

USER ${UGNAME}
EXPOSE 9091/tcp 51413/tcp 51413/udp
ENTRYPOINT [ \
    "/usr/bin/transmission-daemon", "--foreground", \
    "--config-dir", "/var/lib/transmission", \
    "--logfile", "/var/log/transmission/log" \
]
