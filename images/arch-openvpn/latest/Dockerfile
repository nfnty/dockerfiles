FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="190000" UGNAME="openvpn" PRIMPATH="/openvpn"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner=root --group=root --mode=700 \
        "${PRIMPATH}/"{,config,crypto,scripts}
ADD config/ ${PRIMPATH}/config/
ADD scripts/ ${PRIMPATH}/scripts/
RUN chown --recursive "root:root" "${PRIMPATH}/"{config,scripts} && \
    chmod --recursive 'u=rwX,g=,o=' "${PRIMPATH}/"{config,scripts}
VOLUME ["${PRIMPATH}/crypto"]

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}"{data,tmp} && \
        rmdir /tmp && \
        ln --symbolic "${PRIMPATH}/tmp" /tmp
VOLUME ["${PRIMPATH}/data", "${PRIMPATH}/tmp"]

ENV OPENVPN_VERSION="2.3.6-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "openvpn=${OPENVPN_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER root
EXPOSE 1194
ENTRYPOINT ["/openvpn/scripts/entrypoint.sh"]
