FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='290000' UGNAME='heka'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_HEKA='0.10.0-2'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "heka=${VERSION_HEKA}" geoip-citydata && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    chown --recursive "${UGNAME}:${UGNAME}" /var/cache/hekad

USER ${UGNAME}
VOLUME ["/var/cache/hekad"]
EXPOSE 4352/tcp
ENTRYPOINT ["/usr/bin/hekad", "-config=/etc/heka/conf.d/"]
