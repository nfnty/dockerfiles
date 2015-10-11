FROM nfnty/arch-mini:latest

MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="220000" UGNAME="dovecot" PRIMPATH="/dovecot"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=500 \
        "${PRIMPATH}/"{,config,crypto} && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{lib,log,maildir,run,tmp} && \
    ln --symbolic "${PRIMPATH}/lib" /var/lib/dovecot && \
    ln --symbolic "${PRIMPATH}/run" /run/dovecot && \
    rmdir /tmp && \
    ln --symbolic "${PRIMPATH}/tmp" /tmp
VOLUME ["${PRIMPATH}/lib", "${PRIMPATH}/log", "${PRIMPATH}/maildir", "${PRIMPATH}/run", "${PRIMPATH}/tmp"]

ENV DOVECOT_VERSION="2.2.19-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "dovecot=${DOVECOT_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_bind_service=ep' /usr/bin/dovecot && \
    setcap 'cap_sys_chroot=ep' /usr/lib/dovecot/anvil && \
    setcap 'cap_sys_chroot=ep' /usr/lib/dovecot/imap-login

USER ${UGNAME}
EXPOSE 24/tcp 143/tcp
ENTRYPOINT ["/usr/bin/dovecot", "-F", "-c", "/dovecot/config/dovecot.conf"]
