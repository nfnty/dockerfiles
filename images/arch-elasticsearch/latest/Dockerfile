FROM nfnty/arch-jre8:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='110000' UGNAME='elasticsearch'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV ELASTICSEARCH_VERSION='2.0.0' JAVA_HOME='/usr/lib/jvm/default-runtime'
RUN mkdir /opt/elasticsearch && \
    curl "https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/${ELASTICSEARCH_VERSION}/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz" | \
        tar --extract --file=- --gzip --strip-components=1 --directory='/opt/elasticsearch' && \
    chmod --recursive 'u=rwX,g=rX,o=rX' /opt/elasticsearch && \
    sed --in-place --expression='s|^args=.*|args="--"|' /opt/elasticsearch/bin/elasticsearch && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        /var/lib/elasticsearch /var/log/elasticsearch

USER ${UGNAME}
VOLUME ["/var/lib/elasticsearch", "/var/log/elasticsearch"]
EXPOSE 9200/tcp 9300/tcp
ENTRYPOINT ["/opt/elasticsearch/bin/elasticsearch"]
