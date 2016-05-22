FROM nfnty/arch-mono:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='280000' UGNAME='emby'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_EMBY='3.0.5970-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "emby-server=${VERSION_EMBY}" tini && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    chown --recursive "${UGNAME}:${UGNAME}" /var/lib/emby

USER ${UGNAME}
VOLUME ["/var/lib/emby"]
EXPOSE 1900/udp 7359/udp 8096/tcp 8920/tcp
WORKDIR /usr/lib/emby-server
ENTRYPOINT [ \
    "/usr/bin/tini", "--", \
    "/usr/bin/mono", "/usr/lib/emby-server/MediaBrowser.Server.Mono.exe", \
    "-programdata", "/var/lib/emby", \
    "-ffmpeg", "/usr/bin/ffmpeg", \
    "-ffprobe", "/usr/bin/ffprobe" \
]
