FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

COPY ["etc/pacman.conf", "/etc/"]
COPY ["scripts/", "/opt/bootstrap/"]
RUN chmod 'u=rw,g=r,o=r' /etc/pacman.conf && \
    pacman --sync --clean --clean --noconfirm && \
    \
    chmod --recursive 'u=rX,g=,o=' /opt/bootstrap && \
    \
    pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm arch-install-scripts && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    perl -p -i -e 's|^(chroot_setup )|#\1|' /usr/bin/pacstrap && \
    \
    install --directory --owner=root --group=root --mode=700 /var/lib/bootstrap/{,archive}

USER root
VOLUME ["/var/lib/bootstrap"]
ENTRYPOINT ["/opt/bootstrap/build.sh"]
