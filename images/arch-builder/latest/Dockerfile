FROM nfnty/arch-devel:latest

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="99999" UGNAME="builder" PRIMPATH="/builder"

ENV GNUPGHOME="${PRIMPATH}/crypto/gnupg"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false --home-dir "${PRIMPATH}/home" "${UGNAME}"

RUN install --directory --owner=root --group="${UGNAME}" --mode=750 \
        "${PRIMPATH}/"{,config,host,host/pkgbuild,scripts}
ADD config/makepkg.conf ${PRIMPATH}/config/
ADD scripts/ ${PRIMPATH}/scripts/
RUN chown --recursive "root:${UGNAME}" "${PRIMPATH}/"{config,scripts} && \
    chmod --recursive 'u=rwX,g=rX,o=' "${PRIMPATH}/"{config,scripts}

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{pkgbuild,builddir,pkgdest,srcdest,srcpkgdest,logs,home} \
        "${GNUPGHOME}"
ADD config/gnupg/ ${GNUPGHOME}/
RUN chown --recursive "${UGNAME}:${UGNAME}" "${GNUPGHOME}" && \
    chmod --recursive 'u=rwX,g=,o=' "${GNUPGHOME}"
VOLUME ["${PRIMPATH}/pkgdest", "${PRIMPATH}/srcdest", "${PRIMPATH}/logs", "${GNUPGHOME}"]

ADD config/sudoers /etc/
RUN chown 'root:root' /etc/sudoers && \
    chmod 'u=r,g=r,o=' /etc/sudoers

RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm python-requests python-pygit2 && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER ${UGNAME}
ENTRYPOINT ["/builder/scripts/builder.py"]
