FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880022' && \
    groupadd --gid "${ugid}" dovecot && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false dovecot

ENV VERSION_DOVECOT='2.3.4-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "dovecot=${VERSION_DOVECOT}" pigeonhole && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner=dovecot --group=dovecot --mode=700 /var/lib/dovecot /var/log/dovecot && \
    install --directory --owner=dovecot --group=dovecot --mode=755 /run/dovecot

USER dovecot
VOLUME ["/var/lib/dovecot"]
EXPOSE 10024/tcp 10993/tcp
ENTRYPOINT ["/usr/bin/dovecot", "-F"]
