FROM nfnty/arch-java:jre8-openjdk-headless

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="110000" UGNAME="elasticsearch" PRIMPATH="/elasticsearch"

ENV JAVA_HOME="/usr/lib/jvm/default-runtime"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner=root --group="${UGNAME}" --mode=750 \
        "${PRIMPATH}/"{,bin,config}
ADD config/ ${PRIMPATH}/config/
RUN chown --recursive "root:${UGNAME}" "${PRIMPATH}/config" && \
    chmod --recursive 'u=rwX,g=rX,o=' "${PRIMPATH}/config"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{data,logs,work,plugins}
VOLUME ["${PRIMPATH}/data", "${PRIMPATH}/logs"]

RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm util-linux && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

ENV ELASTICSEARCH_VERSION="1.5.0"
RUN curl "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz" | \
        tar --extract --gzip --strip-components=1 --file=- --directory="${PRIMPATH}/bin" && \
    chown --recursive "root:${UGNAME}" "${PRIMPATH/bin}" && \
    chmod --recursive 'u=rwX,g=rX,o=' "${PRIMPATH}/bin"  && \
    rm --recursive "${PRIMPATH}/bin/config" && \
    ln --symbolic "${PRIMPATH}/config" "${PRIMPATH}/bin/config"

USER ${UGNAME}
EXPOSE 9200 9300
ENTRYPOINT ["/elasticsearch/bin/bin/elasticsearch"]
