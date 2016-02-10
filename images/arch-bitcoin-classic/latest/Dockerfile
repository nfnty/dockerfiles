FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='330000' UGNAME='bitcoin'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_BITCOIN_CLASSIC='0.11.2.cl1-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "bitcoin-classic=${VERSION_BITCOIN_CLASSIC}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 /var/lib/bitcoin

USER ${UGNAME}
VOLUME ["/var/lib/bitcoin"]
EXPOSE 8333/tcp
ENTRYPOINT ["/usr/bin/bitcoind", "-conf=/etc/bitcoin/bitcoin.conf", "-datadir=/var/lib/bitcoin"]
