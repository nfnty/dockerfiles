FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='260000' UGNAME='kea'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_KEA='1.0.0-1' KEA_PIDFILE_DIR='/run/kea' KEA_LOGGER_DESTINATION='/var/log/kea/kea.log'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "kea=${VERSION_KEA}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_bind_service,cap_net_raw=ep' /usr/bin/kea-dhcp4 && \
    setcap 'cap_net_bind_service,cap_net_raw=ep' /usr/bin/kea-dhcp6 && \
    chown --recursive "${UGNAME}:${UGNAME}" /var/lib/kea /var/log/kea && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 /run/kea

USER ${UGNAME}
VOLUME ["/var/lib/kea", "/var/log/kea"]
ENTRYPOINT ["/usr/bin/kea-dhcp4", "-c", "/etc/kea/kea.conf"]
