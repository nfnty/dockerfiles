FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='0' UGNAME='root' GNUPGHOME='/var/lib/bootstrap/gnupg'
RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        /var/lib/bootstrap/{,archive,gnupg}

COPY ["gnupg/", "${GNUPGHOME}/"]
COPY ["scripts/", "/opt/bootstrap/"]
RUN chmod --recursive 'u=rX,g=,o=' /opt/bootstrap && \
    chmod --recursive 'u=rwX,g=,o=' "${GNUPGHOME}" && \

    pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm arch-install-scripts && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    perl -p -i -e 's/^chroot_setup\ /#chroot_setup\ /g' /usr/bin/pacstrap

USER ${UGNAME}
VOLUME ["/var/lib/bootstrap"]
ENTRYPOINT ["/opt/bootstrap/build.sh"]
