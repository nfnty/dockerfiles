FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="240000" UGNAME="powerdns" PRIMPATH="/powerdns"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=500 \
        "${PRIMPATH}/"{,config,crypto} && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/run" && \
        rmdir /run && \
        ln --symbolic "${PRIMPATH}/run" /run
VOLUME ["${PRIMPATH}/run"]

ENV POWERDNS_RECURSOR_VERSION="3.7.2-2"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "powerdns-recursor=${POWERDNS_RECURSOR_VERSION}" lua-luajson && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_bind_service=ep' /usr/bin/pdns_recursor

USER ${UGNAME}
EXPOSE 53/tcp 53/udp
ENTRYPOINT ["/usr/bin/pdns_recursor", "--config-dir=/powerdns/config"]
