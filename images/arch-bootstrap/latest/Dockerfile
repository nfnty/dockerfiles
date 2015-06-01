FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="0" UGNAME="root" PRIMPATH="/bootstrap"

ENV GNUPGHOME="${PRIMPATH}/crypto/gnupg"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=500 \
        "${PRIMPATH}/"{,config,crypto,scripts} && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{cache,dest,rootfs} \
        "${GNUPGHOME}" && \
    rmdir /var/cache/pacman/pkg && \
    ln --symbolic "${PRIMPATH}/cache" /var/cache/pacman/pkg
VOLUME ["${PRIMPATH}/cache", "${PRIMPATH}/dest", "${PRIMPATH}/rootfs", "${GNUPGHOME}"]

ADD config/packages ${PRIMPATH}/config/
ADD scripts/ ${PRIMPATH}/scripts/
ADD config/gnupg/ ${GNUPGHOME}/
RUN chown --recursive "${UGNAME}:${UGNAME}" "${PRIMPATH}/"{config,scripts} && \
    chmod --recursive 'u=rX,g=,o=' "${PRIMPATH}/"{config,scripts} && \
    chown --recursive "${UGNAME}:${UGNAME}" "${GNUPGHOME}" && \
    chmod --recursive 'u=rwX,g=,o=' "${GNUPGHOME}"

RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm arch-install-scripts && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    perl -p -i -e 's/^chroot_setup\ /#chroot_setup\ /g' /usr/bin/pacstrap

USER ${UGNAME}
ENTRYPOINT ["/bootstrap/scripts/build.sh"]
