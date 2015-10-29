FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="180000" UGNAME="postgres"
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV POSTGRESQL_VERSION="9.4.5-1" PGDATA="/var/lib/postgres/data"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "postgresql=${POSTGRESQL_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        /run/postgresql /var/lib/postgres
VOLUME ["/var/lib/postgres"]

USER ${UGNAME}
EXPOSE 5432/tcp
ENTRYPOINT ["/usr/bin/postgres"]
