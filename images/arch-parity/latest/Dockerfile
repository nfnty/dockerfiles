FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='430000' UGNAME='parity'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false --home-dir /var/lib/parity/home "${UGNAME}"

ENV VERSION_PARITY='1.3.1-1'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "nfnty/parity=${VERSION_PARITY}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 /var/lib/parity/home

USER ${UGNAME}
VOLUME ["/var/lib/parity"]
EXPOSE  8080/tcp 8180/tcp 8545/tcp 30303/tcp 30303/udp
ENTRYPOINT [ \
    "/usr/bin/parity", \
    "--db-path", "/var/lib/parity/db", \
    "--keys-path", "/var/lib/parity/keys", \
    "--signer-path", "/var/lib/parity/signer", \
    "--ipc-path", "/var/lib/parity/ipc", \
    "--dapps-path", "/var/lib/parity/dapps" \
]
