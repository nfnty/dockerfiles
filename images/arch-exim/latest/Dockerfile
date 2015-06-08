FROM nfnty/arch-mini:latest

MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="250000" UGNAME="exim" PRIMPATH="/exim"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner="${UGNAME}" --group=root --mode=550 \
        "${PRIMPATH}/"{,config,crypto} && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{log,spool,spool/db}
VOLUME ["${PRIMPATH}/log", "${PRIMPATH}/spool"]

ENV EXIM_VERSION="4.85-2"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "exim=${EXIM_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    rm --recursive /var/spool/exim && \
    ln --symbolic "${PRIMPATH}/spool" /var/spool/exim && \
    rmdir /var/log/exim && \
    ln --symbolic "${PRIMPATH}/log" /var/log/exim && \
    rm /etc/mail/exim.conf && \
    ln --symbolic "${PRIMPATH}/config/exim.conf" /etc/mail/exim.conf

USER root
EXPOSE 25/tcp 587/tcp
ENTRYPOINT ["/usr/bin/exim", "-bdf", "-q30m"]
