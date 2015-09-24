FROM nfnty/arch-jre8:latest

MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="110000" UGNAME="elasticsearch" PRIMPATH="/elasticsearch"

ENV JAVA_HOME="/usr/lib/jvm/default-runtime"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=500 \
        "${PRIMPATH}/"{,bin,config} && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{data,logs,plugins,tmp,work} && \
    rmdir /tmp && \
    ln --symbolic "${PRIMPATH}/tmp" /tmp
VOLUME ["${PRIMPATH}/data", "${PRIMPATH}/logs", "${PRIMPATH}/tmp", "${PRIMPATH}/work"]

ENV ELASTICSEARCH_VERSION="1.7.2"
RUN curl "https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz" | \
        tar --extract --gzip --strip-components=1 --file=- --directory="${PRIMPATH}/bin" && \
    chown --recursive "${UGNAME}:${UGNAME}" "${PRIMPATH/bin}" && \
    chmod --recursive 'u=rX,g=,o=' "${PRIMPATH}/bin"  && \
    rm --recursive "${PRIMPATH}/bin/config" && \
    ln --symbolic "${PRIMPATH}/config" "${PRIMPATH}/bin/config" && \
    perl -p -i -e 's/^args=.*/args="--"/' "${PRIMPATH}/bin/bin/elasticsearch"

USER ${UGNAME}
EXPOSE 9200/tcp 9300/tcp
ENTRYPOINT ["/elasticsearch/bin/bin/elasticsearch"]
