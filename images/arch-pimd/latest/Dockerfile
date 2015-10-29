FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="300000" UGNAME="pimd"
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV PIMD_VERSION="2.3.1-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "pimd=${PIMD_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_admin,cap_net_raw=ep' /usr/bin/pimd

USER ${UGNAME}
ENTRYPOINT ["/usr/bin/pimd", "--foreground", "--disable-vifs"]
