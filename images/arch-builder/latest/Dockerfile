FROM nfnty/arch-devel:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='99999' UGNAME='builder' GNUPGHOME='/var/lib/builder/gnupg'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false --home-dir /tmp/home "${UGNAME}" && \

    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        /tmp/{build,home,pkgbuild} /var/lib/builder/{,gnupg,pkg,src} /var/log/builder

COPY ["etc/", "/etc/"]
COPY ["gnupg/", "${GNUPGHOME}/"]
COPY ["scripts/", "/opt/builder/"]
RUN chmod 'u=rw,g=r,o=r' /etc/makepkg.conf && \
    chmod 'u=r,g=r,o=' /etc/sudoers && \
    chown --recursive "${UGNAME}:${UGNAME}" "${GNUPGHOME}" && \
    chmod --recursive 'u=rwX,g=,o=' "${GNUPGHOME}" && \
    chmod --recursive 'u=rwX,g=rX,o=rX' /opt/builder && \

    pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm python-requests && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \

    perl -0777 -p -i -e 's|#(\[multilib\]\n)#(Include = /etc/pacman.d/mirrorlist)|\1\2|s' /etc/pacman.conf

USER ${UGNAME}
VOLUME ["/var/lib/builder", "/var/log/builder"]
ENTRYPOINT ["/opt/builder/builder.py"]
