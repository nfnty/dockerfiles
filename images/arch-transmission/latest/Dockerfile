FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="100000" UGNAME="transmission" PRIMPATH="/transmission"

ENV TORRENTPATH="/torrent"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner=root --group="${UGNAME}" --mode=750 \
        "${PRIMPATH}/"{,scripts} \
        "${TORRENTPATH}"
ADD scripts/ ${PRIMPATH}/scripts/
RUN chown --recursive "root:${UGNAME}" "${PRIMPATH}/scripts" && \
    chmod --recursive 'u=rwX,g=rX,o=' "${PRIMPATH}/scripts"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/config" \
        "${TORRENTPATH}/"{completed,downloading,seeding}
ADD config/ ${PRIMPATH}/config/
RUN chown --recursive "${UGNAME}:${UGNAME}" "${PRIMPATH}/config" && \
    chmod --recursive 'u=rwX,g=rX,o=' "${PRIMPATH}/config"
VOLUME ["${PRIMPATH}/config"]

ENV TRANSMISSION_VERSION="2.84-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "transmission-cli=${TRANSMISSION_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER ${UGNAME}
EXPOSE 9091 51413
ENTRYPOINT ["/usr/bin/transmission-daemon", "--foreground", "--config-dir", "/transmission/config"]
