FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880032' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false --home-dir /var/lib/plexmediaserver/home contusr

ENV VERSION_PLEX='0.9.16.6.1993-5089475' \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR='/var/lib/plexmediaserver/appsupport' \
    PLEX_MEDIA_SERVER_HOME='/opt/plexmediaserver' \
    LD_LIBRARY_PATH='/opt/plexmediaserver' \
    PLEX_MEDIA_SERVER_TMPDIR='/tmp' \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6
RUN mkdir /opt/plexmediaserver && \
    set -o pipefail && \
    curl --speed-limit 256000 \
        "https://downloads.plex.tv/plex-media-server/${VERSION_PLEX}/plexmediaserver-${VERSION_PLEX}.x86_64.rpm" | \
        bsdtar --extract --file=- --include='usr/lib/plexmediaserver' --strip-components=4 --directory='/opt/plexmediaserver' && \
    chmod --recursive 'u=rwX,g=rX,o=rX' /opt/plexmediaserver && \
    install --directory --owner=contusr --group=contgrp --mode=700 \
        /var/lib/plexmediaserver{,home,appsupport}

USER contusr
VOLUME ["/var/lib/plexmediaserver"]
EXPOSE 32400
ENTRYPOINT ["/opt/plexmediaserver/Plex Media Server"]
