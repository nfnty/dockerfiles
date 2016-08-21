FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='410000' UGNAME='rspamd'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_RSPAMD='1.3.3-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nfnty/rspamd=${VERSION_RSPAMD}" file && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 /var/lib/rspamd

USER ${UGNAME}
VOLUME ["/var/lib/rspamd"]
EXPOSE 11333/tcp 11334/tcp
ENTRYPOINT ["/usr/bin/rspamd", "--config=/etc/rspamd/rspamd.conf", "--no-fork"]
