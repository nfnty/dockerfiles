FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='230000' UGNAME='ntp'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV NTP_VERSION='4.2.8.p4-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "ntp=${NTP_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_ipc_lock,cap_net_bind_service,cap_sys_time=ep' /usr/bin/ntpd && \
    chown --recursive "${UGNAME}:${UGNAME}" /var/lib/ntp

USER ${UGNAME}
VOLUME ["/var/lib/ntp"]
EXPOSE 123/udp
ENTRYPOINT ["/usr/bin/ntpd", "--nofork", "--panicgate"]
