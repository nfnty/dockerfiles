FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880025' && \
    groupadd --gid "${ugid}" exim && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false --home-dir /var/spool/exim exim

ENV VERSION_EXIM='4.91-2'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "exim=${VERSION_EXIM}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    chmod -s /usr/bin/exim && \
    setcap \
        'cap_net_bind_service=eip' /usr/bin/tini \
        'cap_net_bind_service=ei' /usr/bin/exim && \
    install --directory --owner=exim --group=exim --mode=700 /var/log/exim /var/spool/exim

USER exim
VOLUME ["/var/spool/exim"]
EXPOSE 25/tcp 587/tcp
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/bin/exim", "-bdf", "-q30m"]
