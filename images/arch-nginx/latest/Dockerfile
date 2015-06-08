FROM nfnty/arch-mini:latest

MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="160000" UGNAME="nginx" PRIMPATH="/nginx"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=500 \
        "${PRIMPATH}"{,config,content,crypto} && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}"{lib,lib/proxy,log}
VOLUME ["${PRIMPATH}/lib", "${PRIMPATH}/log"]

ENV NGINX_VERSION="1.8.0-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nginx=${NGINX_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_bind_service=ep' /usr/bin/nginx && \
    rm --recursive /var/lib/nginx && \
    ln --symbolic "${PRIMPATH}/lib" /var/lib/nginx

USER ${UGNAME}
EXPOSE 80/tcp 443/tcp
ENTRYPOINT ["/usr/bin/nginx", "-c", "/nginx/config/nginx.conf", "-g", "daemon off;"]
