FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="160000" UGNAME="nginx" PRIMPATH="/nginx"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner=root --group="${UGNAME}" --mode=750 \
        "${PRIMPATH}/"{,htpasswd} && \
    install --directory --owner=root --group=root --mode=700 \
        "${PRIMPATH}/"{config,crypto}
ADD config/ ${PRIMPATH}/config/
RUN chown --recursive "root:${UGNAME}" "${PRIMPATH}/config" && \
    chmod --recursive 'u=rwX,g=rX,o=' "${PRIMPATH}/config"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/data"

ENV NGINX_VERSION="1.8.0-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nginx=${NGINX_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    mv /var/lib/nginx "${PRIMPATH}/lib" && \
    ln --symbolic "${PRIMPATH}/lib" /var/lib/nginx
VOLUME ["${PRIMPATH}/lib"]

USER root
EXPOSE 80 443
ENTRYPOINT ["/usr/bin/nginx", "-c", "/nginx/config/nginx.conf", "-g", "daemon off;"]
