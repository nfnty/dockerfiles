FROM nfnty/arch-mono:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880028' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_EMBY='3.4.1.0-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nfnty/emby-server-unlocked=${VERSION_EMBY}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    chown --recursive contusr:contgrp /var/lib/emby

USER contusr
VOLUME ["/var/lib/emby"]
EXPOSE 1900/udp 7359/udp 8096/tcp 8920/tcp
WORKDIR /usr/lib/emby-server
ENTRYPOINT [ \
    "/usr/bin/mono", "/usr/lib/emby-server/MediaBrowser.Server.Mono.exe", \
    "-programdata", "/var/lib/emby", \
    "-ffmpeg", "/usr/bin/ffmpeg", \
    "-ffprobe", "/usr/bin/ffprobe" \
]
