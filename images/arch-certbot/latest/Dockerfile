FROM nfnty/arch-python2:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='99998' UGNAME='certbot'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_CERTBOT='0.8.1-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "certbot=${VERSION_CERTBOT}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    chown --recursive "${UGNAME}:${UGNAME}" /var/lib/letsencrypt /var/log/letsencrypt

USER $UGNAME
VOLUME ["/var/lib/letsencrypt", "/var/log/letsencrypt"]
ENTRYPOINT ["/usr/bin/certbot"]
