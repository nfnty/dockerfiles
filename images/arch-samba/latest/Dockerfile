FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="140000" UGNAME="fileshare" PRIMPATH="/samba"

ENV SHAREPATH="/share"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner=root --group=root --mode=700 \
        "${PRIMPATH}/"{,config,data,data/private}
ADD config/ ${PRIMPATH}/config/
RUN chown --recursive 'root:root' "${PRIMPATH}/config" && \
    chmod --recursive 'u=rwX,g=,o=' "${PRIMPATH}/config"
VOLUME ["${PRIMPATH}/data"]

RUN install --directory --owner=root --group="${UGNAME}" --mode=750 \
        "${SHAREPATH}"

ENV SAMBA_VERSION="4.2.1-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "samba=${SAMBA_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    rm --recursive '/var/lib/samba' && \
    ln --symbolic '/samba/data' '/var/lib/samba'

USER root
EXPOSE 139 445
ENTRYPOINT ["/usr/bin/smbd", "--foreground", "--log-stdout", "--configfile=/samba/config/smb.conf"]
