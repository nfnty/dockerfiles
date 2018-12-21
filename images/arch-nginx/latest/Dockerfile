FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880016' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_NGINX_MAINLINE='1.15.7-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nginx-mainline=${VERSION_NGINX_MAINLINE}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_bind_service=ep' /usr/bin/nginx && \
    chown --recursive contusr:contgrp /var/lib/nginx /var/log/nginx && \
    install --directory --owner=contusr --group=contgrp --mode=700 /run/nginx

USER contusr
VOLUME ["/var/lib/nginx"]
EXPOSE 80/tcp 443/tcp
ENTRYPOINT ["/usr/bin/nginx", "-g", "daemon off;"]
