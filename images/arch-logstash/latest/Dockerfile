FROM nfnty/arch-jre8:latest

MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="130000" UGNAME="logstash" PRIMPATH="/logstash"

ENV JAVA_HOME="/usr/lib/jvm/default-runtime"
ENV SINCEDB_DIR="${PRIMPATH}/sincedb"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=500 \
        "${PRIMPATH}/"{,bin,config,host} && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{bundle,sincedb,tmp} && \
    rmdir /tmp && \
    ln --symbolic "${PRIMPATH}/tmp" /tmp
VOLUME ["${PRIMPATH}/bundle", "${PRIMPATH}/sincedb", "${PRIMPATH}/tmp"]

ENV LOGSTASH_VERSION="1.5.3"
RUN curl "https://download.elastic.co/logstash/logstash/logstash-${LOGSTASH_VERSION}.tar.gz" | \
        tar --extract --gzip --strip-components=1 --file=- --directory="${PRIMPATH}/bin" && \
    chown --recursive "${UGNAME}:${UGNAME}" "${PRIMPATH}/bin" && \
    chmod --recursive 'u=rX,g=,o=' "${PRIMPATH}/bin"  && \
    ln --symbolic "${PRIMPATH}/bundle" "${PRIMPATH}/bin/.bundle"

USER ${UGNAME}
ENTRYPOINT ["/logstash/bin/bin/logstash", "--config", "/logstash/config"]
