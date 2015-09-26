FROM nfnty/arch-mono:latest

MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="280000" UGNAME="emby" PRIMPATH="/emby"
ENV UGID2="140000" UGNAME2="media"

ENV EB_HOME='/opt/emby-server'
ENV EB_DATA="${PRIMPATH}/lib"
ENV EB_PIDFILE="${PRIMPATH}/tmp/emby.pid"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}" && \
    groupadd --gid "${UGID2}" "${UGNAME2}" && \
    gpasswd --add "${UGNAME}" "${UGNAME2}"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=500 \
        "${PRIMPATH}/"{,media} && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{lib,tmp} && \
    rmdir /tmp && \
    ln --symbolic "${PRIMPATH}/tmp" /tmp
VOLUME ["${PRIMPATH}/lib", "${PRIMPATH}/tmp"]

ENV EMBY_VERSION="3.0.5724.5-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm emby-server="${EMBY_VERSION}" openjpeg2 libpng libwebp && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER ${UGNAME}
EXPOSE 1900/udp 7359/udp 8096/tcp 8920/tcp
ENTRYPOINT [ \
    "/usr/bin/mono", "/opt/emby-server/MediaBrowser.Server.Mono.exe", \
    "-programdata", "/emby/lib", \
    "-ffmpeg", "/usr/bin/ffmpeg", \
    "-ffprobe", "/usr/bin/ffprobe" \
]
