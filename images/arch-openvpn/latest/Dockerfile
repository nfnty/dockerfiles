FROM nfnty/arch-mini:latest

MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="190000" UGNAME="openvpn" PRIMPATH="/openvpn"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner="${UGNAME}" --group=root --mode=550 \
        "${PRIMPATH}/"{,config,crypto,scripts} && \
    install --directory --owner="${UGNAME}" --group=root --mode=770 \
        "${PRIMPATH}"{data,tmp} && \
        rmdir /tmp && \
        ln --symbolic "${PRIMPATH}/tmp" /tmp
VOLUME ["${PRIMPATH}/data", "${PRIMPATH}/tmp"]

ENV OPENVPN_VERSION="2.3.8-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "openvpn=${OPENVPN_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER root
EXPOSE 1194/tcp 1194/udp
ENTRYPOINT ["/openvpn/scripts/entrypoint.sh"]
