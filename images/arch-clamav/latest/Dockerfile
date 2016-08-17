FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='400000' UGNAME='clamav'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_CLAMAV='0.99.2-2'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "clamav=${VERSION_CLAMAV}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    chown --recursive "${UGNAME}:${UGNAME}" /var/lib/clamav

USER ${UGNAME}
VOLUME ["/var/lib/clamav"]
EXPOSE 3310/tcp
ENTRYPOINT ["/usr/bin/clamd"]
