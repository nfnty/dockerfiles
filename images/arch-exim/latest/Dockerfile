FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="250000" UGNAME="exim"
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV EXIM_VERSION="4.86-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "exim=${EXIM_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    chmod -s /usr/bin/exim && \
    setcap 'cap_net_bind_service=ep' /usr/bin/exim && \
    chown --recursive "${UGNAME}:${UGNAME}" /etc/mail /var/log/exim /var/spool/exim && \
    chmod --recursive 700 /var/log/exim /var/spool/exim

USER ${UGNAME}
VOLUME ["/var/log/exim", "/var/spool/exim"]
EXPOSE 25/tcp 587/tcp
ENTRYPOINT ["/usr/bin/exim", "-bdf", "-q30m"]
