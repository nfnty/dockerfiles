FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='180000' UGNAME='postgres'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_POSTGRESQL='9.5.1-2' PGDATA='/var/lib/postgres/data'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "postgresql=${VERSION_POSTGRESQL}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        /run/postgresql /var/lib/postgres

USER ${UGNAME}
VOLUME ["/var/lib/postgres"]
EXPOSE 5432/tcp
ENTRYPOINT ["/usr/bin/postgres"]
