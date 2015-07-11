FROM nfnty/arch-mini:latest

MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="140000" UGNAME="samba" PRIMPATH="/samba"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=500 \
        "${PRIMPATH}/"{,config,share} && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{cache,lib,lib/private,log,run} && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=755 \
        "${PRIMPATH}/cache/lck" && \
    ln --symbolic "${PRIMPATH}/run" /run/samba
VOLUME ["${PRIMPATH}/cache", "${PRIMPATH}/lib", "${PRIMPATH}/log", "${PRIMPATH}/run"]

ENV SAMBA_VERSION="4.2.2-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "samba=${SAMBA_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    setcap 'cap_net_bind_service=ep' /usr/bin/smbd && \
    rmdir /var/cache/samba && \
    ln --symbolic "${PRIMPATH}/cache" /var/cache/samba && \
    rm --recursive /var/lib/samba && \
    ln --symbolic "${PRIMPATH}/lib" /var/lib/samba && \
    rmdir /var/log/samba && \
    ln --symbolic "${PRIMPATH}/log" /var/log/samba

USER ${UGNAME}
EXPOSE 139/tcp 445/tcp
ENTRYPOINT ["/usr/bin/smbd", "--foreground", "--log-stdout", "--configfile=/samba/config/smb.conf", "--option=pid directory=/run/samba"]
