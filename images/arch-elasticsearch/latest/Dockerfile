FROM nfnty/arch-jre8:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880011' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_ELASTICSEARCH='2.4.1' JAVA_HOME='/usr/lib/jvm/default-runtime'
RUN mkdir /opt/elasticsearch && \
    set -o pipefail && \
    curl --speed-limit 256000 \
        "https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/${VERSION_ELASTICSEARCH}/elasticsearch-${VERSION_ELASTICSEARCH}.tar.gz" | \
        tar --extract --file=- --gzip --strip-components=1 --directory='/opt/elasticsearch' && \
    chmod --recursive 'u=rwX,g=rX,o=rX' /opt/elasticsearch && \
    install --directory --owner=contusr --group=contgrp --mode=700 \
        /var/lib/elasticsearch /var/log/elasticsearch

USER contusr
VOLUME ["/var/lib/elasticsearch"]
EXPOSE 9200/tcp 9300/tcp
ENTRYPOINT ["/opt/elasticsearch/bin/elasticsearch"]
