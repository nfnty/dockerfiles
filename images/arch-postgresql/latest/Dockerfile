FROM nfnty/arch-mini:latest

MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="180000" UGNAME="postgres" PRIMPATH="/postgres"

ENV PGPASSFILE="${PRIMPATH}/config/pass.conf"
ENV PGSERVICEFILE="${PRIMPATH}/config/service.conf"
ENV PGDATA="${PRIMPATH}/data"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=500 \
        "${PRIMPATH}/"{,config,crypto} && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{data,run} && \
        ln --symbolic "${PRIMPATH}/run" /run/postgresql
VOLUME ["${PRIMPATH}/data", "${PRIMPATH}/run"]

ENV POSTGRESQL_VERSION="9.4.4-2"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "postgresql=${POSTGRESQL_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER ${UGNAME}
EXPOSE 5432/tcp
ENTRYPOINT ["/usr/bin/postgres"]
