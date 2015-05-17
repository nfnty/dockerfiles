FROM nfnty/arch-java:jre8-openjdk-headless

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="130000" UGNAME="logstash" PRIMPATH="/logstash"

ENV JAVA_HOME="/usr/lib/jvm/default-runtime"
ENV SINCEDB_DIR="${PRIMPATH}/data/sincedb"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner=root --group="${UGNAME}" --mode=750 \
        "${PRIMPATH}/"{,bin,config,host}
ADD config/ ${PRIMPATH}/config/
RUN chown --recursive "root:${UGNAME}" "${PRIMPATH}/config" && \
    chmod --recursive 'u=rwX,g=rX,o=' "${PRIMPATH}/config"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{bundle,data,data/sincedb,tmp} && \
    rmdir /tmp && \
    ln --symbolic "${PRIMPATH}/tmp" /tmp
VOLUME ["${PRIMPATH}/data", "${PRIMPATH}/tmp"]

ENV LOGSTASH_VERSION="1.4.2"
RUN curl "https://download.elasticsearch.org/logstash/logstash/logstash-${LOGSTASH_VERSION}.tar.gz" | \
        tar --extract --gzip --strip-components=1 --file=- --directory="${PRIMPATH}/bin" && \
    chown --recursive "root:${UGNAME}" "${PRIMPATH}/bin" && \
    chmod --recursive 'u=rwX,g=rX,o=' "${PRIMPATH}/bin"  && \
    ln --symbolic "${PRIMPATH}/bundle" "${PRIMPATH}/bin/.bundle"

USER ${UGNAME}
ENTRYPOINT ["/logstash/bin/bin/logstash", "--config", "/logstash/config"]
