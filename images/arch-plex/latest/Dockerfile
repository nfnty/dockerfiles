FROM nfnty/arch-mini:latest

MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='320000' UGNAME='plex' UGID2='140000' UGNAME2='media'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false \
        --home-dir /var/lib/plexmediaserver/home "${UGNAME}" && \
    groupadd --gid "${UGID2}" "${UGNAME2}" && \
    gpasswd --add "${UGNAME}" "${UGNAME2}"

ENV PLEX_VERSION='0.9.12.18.1520-6833552' \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR='/var/lib/plexmediaserver/appsupport' \
    PLEX_MEDIA_SERVER_HOME='/opt/plexmediaserver' \
    LD_LIBRARY_PATH='/opt/plexmediaserver' \
    PLEX_MEDIA_SERVER_TMPDIR='/tmp' \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6
RUN mkdir /opt/plexmediaserver && \
    curl "https://downloads.plex.tv/plex-media-server/${PLEX_VERSION}/plexmediaserver-${PLEX_VERSION}.x86_64.rpm" | \
        bsdtar --directory /opt/plexmediaserver --include='usr/lib/plexmediaserver' --strip-components 4 --extract --file - && \
    chmod --recursive 'u=rwX,g=rX,o=rX' /opt/plexmediaserver && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        /var/lib/plexmediaserver{,home,appsupport}

USER ${UGNAME}
VOLUME ["/var/lib/plexmediaserver"]
EXPOSE 32400
ENTRYPOINT ["/opt/plexmediaserver/Plex Media Server"]
