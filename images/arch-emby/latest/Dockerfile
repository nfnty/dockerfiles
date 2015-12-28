FROM nfnty/arch-mono:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='280000' UGNAME='emby' UGID2='140000' UGNAME2='media'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}" && \
    groupadd --gid "${UGID2}" "${UGNAME2}" && \
    gpasswd --add "${UGNAME}" "${UGNAME2}"

ENV EMBY_VERSION='3.0.5782.0-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "emby-server=${EMBY_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 /var/lib/emby

USER ${UGNAME}
VOLUME ["/var/lib/emby"]
EXPOSE 1900/udp 7359/udp 8096/tcp 8920/tcp
WORKDIR /usr/lib/emby-server
ENTRYPOINT [ \
    "/usr/bin/mono", "/usr/lib/emby-server/MediaBrowser.Server.Mono.exe", \
    "-programdata", "/var/lib/emby", \
    "-ffmpeg", "/usr/bin/ffmpeg", \
    "-ffprobe", "/usr/bin/ffprobe" \
]
