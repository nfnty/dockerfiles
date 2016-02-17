FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='320000' UGNAME='plex'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false \
        --home-dir /var/lib/plexmediaserver/home "${UGNAME}"

ENV VERSION_PLEX='0.9.15.3.1674-f46e7e6' \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR='/var/lib/plexmediaserver/appsupport' \
    PLEX_MEDIA_SERVER_HOME='/opt/plexmediaserver' \
    LD_LIBRARY_PATH='/opt/plexmediaserver' \
    PLEX_MEDIA_SERVER_TMPDIR='/tmp' \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6
RUN mkdir /opt/plexmediaserver && \
    curl --speed-limit 256000 \
        "https://downloads.plex.tv/plex-media-server/${VERSION_PLEX}/plexmediaserver-${VERSION_PLEX}.x86_64.rpm" | \
        bsdtar --extract --file=- --include='usr/lib/plexmediaserver' --strip-components=4 --directory='/opt/plexmediaserver' && \
    chmod --recursive 'u=rwX,g=rX,o=rX' /opt/plexmediaserver && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        /var/lib/plexmediaserver{,home,appsupport}

USER ${UGNAME}
VOLUME ["/var/lib/plexmediaserver"]
EXPOSE 32400
ENTRYPOINT ["/opt/plexmediaserver/Plex Media Server"]
