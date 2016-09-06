FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='420000' UGNAME='radvd'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_RADVD='2.14-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "radvd=${VERSION_RADVD}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_raw=ep' /usr/bin/radvd

USER ${UGNAME}
ENTRYPOINT ["/usr/bin/radvd", "--nodaemon", "--logmethod=stderr"]
