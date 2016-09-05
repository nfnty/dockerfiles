FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='390000' UGNAME='acoustid-index'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm nfnty/acoustid-index-git && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 /var/lib/acoustid-index

USER ${UGNAME}
VOLUME ["/var/lib/acoustid-index"]
EXPOSE 6080/tcp
ENTRYPOINT ["/usr/bin/fpi-server", "--directory", "/var/lib/acoustid-index", "--address", "::"]
