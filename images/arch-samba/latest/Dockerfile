FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="140000" UGNAME="samba"
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV SAMBA_VERSION="4.3.1-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "samba=${SAMBA_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_bind_service=ep' /usr/bin/smbd && \
    chown --recursive "${UGNAME}:${UGNAME}" /var/cache/samba /var/lib/samba /var/log/samba
VOLUME ["/var/cache/samba", "/var/lib/samba", "/var/log/samba"]

USER ${UGNAME}
EXPOSE 139/tcp 445/tcp
ENTRYPOINT ["/usr/bin/smbd", "--foreground", "--option=pid directory=/run/samba"]
