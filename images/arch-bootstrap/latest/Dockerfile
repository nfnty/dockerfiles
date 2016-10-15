FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN install --directory --owner=root --group=root --mode=700 \
        /var/lib/bootstrap/{,archive,gnupg}
ENV GNUPGHOME='/var/lib/bootstrap/gnupg'
COPY ["etc/pacman.conf", "/etc/"]
COPY ["gnupg/", "${GNUPGHOME}/"]
COPY ["scripts/", "/opt/bootstrap/"]
RUN chmod 'u=rw,g=r,o=r' /etc/pacman.conf && \

    chmod --recursive 'u=rX,g=,o=' /opt/bootstrap && \
    chmod --recursive 'u=rwX,g=,o=' "${GNUPGHOME}" && \

    pacman --sync --clean --clean --noconfirm && \
    pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm arch-install-scripts && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    perl -p -i -e 's|^(chroot_setup )|#\1|' /usr/bin/pacstrap

USER root
VOLUME ["/var/lib/bootstrap"]
ENTRYPOINT ["/opt/bootstrap/build.sh"]
