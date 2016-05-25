FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='340000' UGNAME='rsyslog'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_RSYSLOG='8.18.0-2'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "rsyslog=${VERSION_RSYSLOG}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 /var/log/rsyslog /run

USER ${UGNAME}
VOLUME ["/var/log/rsyslog"]
ENTRYPOINT ["/usr/bin/rsyslogd", "-n", "-i", "/run/rsyslog.pid"]
