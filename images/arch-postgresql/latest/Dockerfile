FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="180000" UGNAME="postgres" PRIMPATH="/postgres"

ENV PGPASSFILE="${PRIMPATH}/config/private/pass.conf"
ENV PGSERVICEFILE="${PRIMPATH}/config/service.conf"
ENV PGDATA="${PRIMPATH}/data"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner=root --group="${UGNAME}" --mode=750 \
        "${PRIMPATH}/"{,config,config/private}
ADD config/ ${PRIMPATH}/config/
RUN chown --recursive "root:${UGNAME}" "${PRIMPATH}/config" && \
    chmod --recursive 'u=rwX,g=rX,o=' "${PRIMPATH}/config" && \
    chown --recursive "${UGNAME}:${UGNAME}" "${PRIMPATH}/config/private" && \
    chmod --recursive 'u=rwX,g=,o=' "${PRIMPATH}/config/private"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{crypto,data,run} && \
        ln --symbolic "${PRIMPATH}/run" /run/postgresql
VOLUME ["${PRIMPATH}/crypto", "${PRIMPATH}/data", "${PRIMPATH}/run"]

ENV POSTGRESQL_VERSION="9.4.1-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "postgresql=${POSTGRESQL_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER ${UGNAME}
EXPOSE 5432
ENTRYPOINT ["/usr/bin/postgres"]
