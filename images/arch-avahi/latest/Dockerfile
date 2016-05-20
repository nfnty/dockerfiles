FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='310000' UGNAME='avahi'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_AVAHI='0.6.32-2'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "avahi=${VERSION_AVAHI}" nss-mdns && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER ${UGNAME}
ENTRYPOINT ["/usr/bin/avahi-daemon", "--no-drop-root"]
