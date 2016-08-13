FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='100000' UGNAME='transmission'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_TRANSMISSION='2.92-5'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "transmission-cli=${VERSION_TRANSMISSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        /var/lib/transmission /var/log/transmission

USER ${UGNAME}
VOLUME ["/var/lib/transmission"]
EXPOSE 9091/tcp 51413/tcp 51413/udp
ENTRYPOINT ["/usr/bin/transmission-daemon", "--foreground", "--config-dir", "/var/lib/transmission"]
