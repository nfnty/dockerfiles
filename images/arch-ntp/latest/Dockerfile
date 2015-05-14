FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="230000" UGNAME="ntp" PRIMPATH="/ntp"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner=root --group="${UGNAME}" --mode=750 \
        "${PRIMPATH}" && \
    install --directory --owner=root --group=root --mode=700 \
        "${PRIMPATH}/config" && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/data"
VOLUME ["${PRIMPATH}/data"]

ENV NTP_VERSION="4.2.8.p2-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "ntp=${NTP_VERSION}" && \
    pacman --sync --noconfirm --clean --clean

USER root
EXPOSE 123
ENTRYPOINT ["/usr/bin/ntpd", "--panicgate", "--user=ntp:ntp", "--configfile=/ntp/config/ntp.conf", "--nofork"]
