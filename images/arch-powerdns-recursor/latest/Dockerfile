FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="240000" UGNAME="powerdns" PRIMPATH="/powerdns"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner=root --group="${UGNAME}" --mode=750 \
        "${PRIMPATH}/"{,config,crypto}
VOLUME ["${PRIMPATH}/crypto"]

ENV POWERDNS_RECURSOR_VERSION="3.7.2-2"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "powerdns-recursor=${POWERDNS_RECURSOR_VERSION}" lua-luajson && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER root
EXPOSE 53
ENTRYPOINT ["/usr/bin/pdns_recursor", "--config-dir=/powerdns/config"]
