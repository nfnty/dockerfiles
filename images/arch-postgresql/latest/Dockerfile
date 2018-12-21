FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880018' && \
    groupadd --gid "${ugid}" postgres && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false postgres

ENV VERSION_POSTGRESQL='11.1-2' PGDATA='/var/lib/postgres/data'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "postgresql=${VERSION_POSTGRESQL}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner=postgres --group=postgres --mode=700 \
        /run/postgresql /var/lib/postgres

USER postgres
VOLUME ["/var/lib/postgres"]
EXPOSE 5432/tcp
ENTRYPOINT ["/usr/bin/postgres"]
