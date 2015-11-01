FROM nfnty/arch-jre8:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="130000" UGNAME="logstash"
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV LOGSTASH_VERSION="2.0.0" JAVA_HOME="/usr/lib/jvm/default-runtime" SINCEDB_DIR="/var/lib/logstash"
RUN mkdir /opt/logstash && \
    curl "https://download.elastic.co/logstash/logstash/logstash-${LOGSTASH_VERSION}.tar.gz" | \
        tar --extract --gzip --strip-components=1 --file=- --directory=/opt/logstash && \
    chmod --recursive 'u=rwX,g=rX,o=rX' /opt/logstash && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        /var/lib/logstash /var/log/logstash

USER ${UGNAME}
VOLUME ["/var/lib/logstash", "/var/log/logstash"]
ENTRYPOINT ["/opt/logstash/bin/logstash", "--config", "/etc/logstash/conf.d", "--log", "/var/log/logstash/log"]
