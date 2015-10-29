FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="260000" UGNAME="kea"
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV KEA_VERSION="0.9.2-3"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "kea=${KEA_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_bind_service,cap_net_raw=ep' /usr/bin/kea-dhcp4 && \
    setcap 'cap_net_bind_service,cap_net_raw=ep' /usr/bin/kea-dhcp6 && \
    chown --recursive "${UGNAME}:${UGNAME}" /var/lib/kea /var/log/kea
VOLUME ["/var/lib/kea", "/var/log/kea"]

USER ${UGNAME}
ENTRYPOINT ["/usr/bin/kea-dhcp4", "-c", "/etc/kea/kea.conf"]
