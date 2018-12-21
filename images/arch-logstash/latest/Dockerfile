FROM nfnty/arch-jre8:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880013' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_LOGSTASH='6.5.4' JAVA_HOME='/usr/lib/jvm/default-runtime' SINCEDB_DIR='/var/lib/logstash'
RUN mkdir /opt/logstash && \
    set -o pipefail && \
    curl --speed-limit 256000 \
        "https://artifacts.elastic.co/downloads/logstash/logstash-${VERSION_LOGSTASH}.tar.gz" | \
        tar --extract --file=- --gzip --strip-components=1 --directory='/opt/logstash' && \
    chmod --recursive 'u=rwX,g=rX,o=rX' /opt/logstash && \
    install --directory --owner=contusr --group=contgrp --mode=700 /var/lib/logstash /var/log/logstash

USER contusr
VOLUME ["/var/lib/logstash"]
ENTRYPOINT ["/opt/logstash/bin/logstash", "--config", "/etc/logstash/conf.d"]
