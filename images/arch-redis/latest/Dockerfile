FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='380000' UGNAME='redis'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_REDIS='3.2.4-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "redis=${VERSION_REDIS}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 /var/lib/redis

USER ${UGNAME}
VOLUME ["/var/lib/redis"]
EXPOSE 6379/tcp
ENTRYPOINT ["/usr/bin/redis-server", "/etc/redis.conf"]
