FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="270000" UGNAME="hostapd"
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV HOSTAPD_VERSION="2.5-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "hostapd=${HOSTAPD_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_admin,cap_net_raw=ep' /usr/bin/hostapd

USER ${UGNAME}
ENTRYPOINT ["/usr/bin/hostapd", "/etc/hostapd/hostapd.conf"]
