FROM nfnty/arch-python2:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='160000' UGNAME='letsencrypt'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_LETSENCRYPT='0.2.0-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "letsencrypt=${VERSION_LETSENCRYPT}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    chown --recursive "${UGNAME}:${UGNAME}" /var/lib/letsencrypt /var/log/letsencrypt

USER $UGNAME
VOLUME ["/var/lib/letsencrypt", "/var/log/letsencrypt"]
ENTRYPOINT ["/usr/bin/letsencrypt"]
