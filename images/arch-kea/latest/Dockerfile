FROM nfnty/arch-mini:latest

MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="260000" UGNAME="kea" PRIMPATH="/kea"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=500 \
        "${PRIMPATH}/"{,config,crypto} && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{data,cache}
VOLUME ["${PRIMPATH}/data", "${PRIMPATH}/cache"]

ENV KEA_VERSION="0.9.1-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "kea=${KEA_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_bind_service,cap_net_raw=ep' /usr/bin/kea-dhcp4 && \
    setcap 'cap_net_bind_service,cap_net_raw=ep' /usr/bin/kea-dhcp6 && \
    rmdir /var/cache/kea && \
    ln --symbolic "${PRIMPATH}/cache" /var/cache/kea

USER ${UGNAME}
