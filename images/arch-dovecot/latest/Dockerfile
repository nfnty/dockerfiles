FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='220000' UGNAME='dovecot'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_DOVECOT='2.2.25-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "dovecot=${VERSION_DOVECOT}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 /var/lib/dovecot /var/log/dovecot && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=755 /run/dovecot

USER ${UGNAME}
VOLUME ["/var/lib/dovecot"]
EXPOSE 10024/tcp 10993/tcp
ENTRYPOINT ["/usr/bin/dovecot", "-F"]
