FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='220000' UGNAME='dovecot'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_DOVECOT='2.2.25-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "dovecot=${VERSION_DOVECOT}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap \
        'cap_sys_chroot,cap_net_bind_service=eip' /usr/bin/dovecot \
        'cap_sys_chroot=eip' /usr/lib/dovecot/anvil \
        'cap_sys_chroot,cap_net_bind_service=eip' /usr/lib/dovecot/lmtp \
        'cap_sys_chroot,cap_net_bind_service=eip' /usr/lib/dovecot/imap-login && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 /var/lib/dovecot /var/log/dovecot && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=755 /run/dovecot

USER ${UGNAME}
VOLUME ["/var/lib/dovecot"]
EXPOSE 24/tcp 143/tcp
ENTRYPOINT ["/usr/bin/dovecot", "-F"]
