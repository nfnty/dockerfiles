FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="230000" UGNAME="ntp" PRIMPATH="/ntp"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner=root --group="${UGNAME}" --mode=550 \
        "${PRIMPATH}" && \
    install --directory --owner=root --group=root --mode=500 \
        "${PRIMPATH}/config" && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/data"
VOLUME ["${PRIMPATH}/data"]

ENV NTP_VERSION="4.2.8.p2-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "ntp=${NTP_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER root
EXPOSE 123/udp
ENTRYPOINT ["/usr/bin/ntpd", "--panicgate", "--user=ntp:ntp", "--configfile=/ntp/config/ntp.conf", "--nofork"]
