FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="240000" UGNAME="powerdns"
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV POWERDNS_RECURSOR_VERSION="3.7.3-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "powerdns-recursor=${POWERDNS_RECURSOR_VERSION}" lua-luajson && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_bind_service=ep' /usr/bin/pdns_recursor

USER ${UGNAME}
EXPOSE 53/tcp 53/udp
ENTRYPOINT ["/usr/bin/pdns_recursor"]
