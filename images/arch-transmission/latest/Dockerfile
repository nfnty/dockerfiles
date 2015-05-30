FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="100000" UGNAME="transmission" PRIMPATH="/transmission"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=500 \
        "${PRIMPATH}/"{,scripts}
ADD scripts/ ${PRIMPATH}/scripts/
RUN chown --recursive "${UGNAME}:${UGNAME}" "${PRIMPATH}/scripts" && \
    chmod --recursive 'u=rX,g=,o=' "${PRIMPATH}/scripts"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{config,torrent,torrent/completed,torrent/downloading,torrent/seeding}
VOLUME ["${PRIMPATH}/config", "${PRIMPATH}/torrent"]

ENV TRANSMISSION_VERSION="2.84-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "transmission-cli=${TRANSMISSION_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER ${UGNAME}
EXPOSE 9091 51413
ENTRYPOINT ["/usr/bin/transmission-daemon", "--foreground", "--config-dir", "/transmission/config"]
