FROM nfnty/arch-jre8:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='130000' UGNAME='logstash'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_LOGSTASH='2.3.1' JAVA_HOME='/usr/lib/jvm/default-runtime' SINCEDB_DIR='/var/lib/logstash'
RUN mkdir /opt/logstash && \
    set -o pipefail && \
    curl --speed-limit 256000 \
        "https://download.elastic.co/logstash/logstash/logstash-${VERSION_LOGSTASH}.tar.gz" | \
        tar --extract --file=- --gzip --strip-components=1 --directory='/opt/logstash' && \
    chmod --recursive 'u=rwX,g=rX,o=rX' /opt/logstash && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 /var/lib/logstash /var/log/logstash

USER ${UGNAME}
VOLUME ["/var/lib/logstash"]
ENTRYPOINT ["/opt/logstash/bin/logstash", "--config", "/etc/logstash/conf.d"]
