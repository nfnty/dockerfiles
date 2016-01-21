FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='220000' UGNAME='dovecot'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_DOVECOT='2.2.21-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "dovecot=${VERSION_DOVECOT}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_bind_service=ep' /usr/bin/dovecot && \
    setcap 'cap_sys_chroot=ep' /usr/lib/dovecot/anvil && \
    setcap 'cap_sys_chroot=ep' /usr/lib/dovecot/imap-login && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        /run/dovecot /var/lib/dovecot /var/log/dovecot

USER ${UGNAME}
VOLUME ["/var/lib/dovecot", "/var/log/dovecot"]
EXPOSE 24/tcp 143/tcp
ENTRYPOINT ["/usr/bin/dovecot", "-F"]
