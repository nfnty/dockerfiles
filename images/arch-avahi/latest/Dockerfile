FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880031' && \
    groupadd --gid "${ugid}" avahi && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false avahi

ENV VERSION_AVAHI='0.7+16+g1cc2b8e-2'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "avahi=${VERSION_AVAHI}" nss-mdns && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER avahi
ENTRYPOINT ["/usr/bin/avahi-daemon", "--no-drop-root"]
