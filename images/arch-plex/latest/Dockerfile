FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="280000" UGNAME="plex" PRIMPATH="/plex"

ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="${PRIMPATH}/appsupport"
ENV PLEX_MEDIA_SERVER_HOME="${PRIMPATH}/bin"
ENV LD_LIBRARY_PATH="${PLEX_MEDIA_SERVER_HOME}"
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6
ENV PLEX_MEDIA_SERVER_TMPDIR="${PRIMPATH}/tmp"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --home-dir "${PRIMPATH}/lib" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=500 \
        "${PRIMPATH}/"{,bin} && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{appsupport,lib,tmp}
VOLUME ["${PRIMPATH}/appsupport", "${PRIMPATH}/lib", "${PRIMPATH}/tmp"]

ENV PLEX_VERSION="0.9.12.1.1079-b655370"
RUN curl "https://downloads.plex.tv/plex-media-server/${PLEX_VERSION}/plexmediaserver-${PLEX_VERSION}.x86_64.rpm" | \
        bsdtar --directory "${PRIMPATH}/bin" --include='usr/lib/plexmediaserver' --strip-components 4 --extract --file - && \
    chown --recursive "${UGNAME}:${UGNAME}" "${PRIMPATH}/bin" && \
    chmod --recursive 'u=rX,g=,o=' "${PRIMPATH}/bin"

USER ${UGNAME}
EXPOSE 32400
ENTRYPOINT ["/plex/bin/Plex Media Server"]
