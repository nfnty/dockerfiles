FROM nfnty/arch-mini:latest

MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="290000" UGNAME="heka" PRIMPATH="/heka"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=500 \
        "${PRIMPATH}/"{,bin,config,host,lua} && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/base"
VOLUME ["${PRIMPATH}/base"]

ENV HEKA_VERSION="0.10.0b0-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm "heka=${HEKA_VERSION}" && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

RUN curl 'https://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz' | \
        gunzip > "${PRIMPATH}/bin/GeoLiteCity.dat" && \
    curl 'https://geolite.maxmind.com/download/geoip/database/GeoLiteCityv6-beta/GeoLiteCityv6.dat.gz' | \
        gunzip > "${PRIMPATH}/bin/GeoLiteCityv6.dat" && \
    chown --recursive "${UGNAME}:${UGNAME}" "${PRIMPATH}/bin" && \
    chmod --recursive 'u=rX,g=,o=' "${PRIMPATH}/bin"

USER ${UGNAME}
EXPOSE 4352/tcp
ENTRYPOINT ["/usr/bin/hekad", "-config", "/heka/config"]
