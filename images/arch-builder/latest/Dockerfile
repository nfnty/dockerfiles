FROM nfnty/arch-devel:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="99999" UGNAME="builder" PRIMPATH="/builder"
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false --home-dir "${PRIMPATH}/home" "${UGNAME}"

ENV GNUPGHOME="${PRIMPATH}/gnupg"
RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=500 "${PRIMPATH}" && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{build,home,log,pkg,pkgbuild,src}
COPY ["primpath/", "${PRIMPATH}/"]
COPY ["etc/", "/etc/"]
RUN chown --recursive "${UGNAME}:${UGNAME}" "${PRIMPATH}/"{config,scripts} "${GNUPGHOME}" && \
    chmod --recursive 'u=rX,g=rX,o=' "${PRIMPATH}/"{config,scripts} && \
    chmod --recursive 'u=rwX,g=,o=' "${GNUPGHOME}" && \
    chown 'root:root' /etc/sudoers && \
    chmod 'u=r,g=r,o=' /etc/sudoers
VOLUME ["${PRIMPATH}/log", "${PRIMPATH}/pkg", "${PRIMPATH}/src", "${GNUPGHOME}"]

RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm python-requests && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER ${UGNAME}
ENTRYPOINT ["/builder/scripts/builder.py"]
