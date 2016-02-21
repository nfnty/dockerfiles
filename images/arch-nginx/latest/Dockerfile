FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='160000' UGNAME='nginx'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_NGINX='1.8.1-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nginx=${VERSION_NGINX}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_bind_service=ep' /usr/bin/nginx && \
    chown --recursive "${UGNAME}:${UGNAME}" /var/lib/nginx /var/log/nginx && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 /run/nginx

USER ${UGNAME}
VOLUME ["/var/lib/nginx"]
EXPOSE 80/tcp 443/tcp
ENTRYPOINT ["/usr/bin/nginx", "-g", "daemon off;"]
