FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880012' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_KIBANA='6.5.4' BABEL_CACHE_PATH='/tmp/babel.json'
RUN install --directory --owner=contusr --group=contgrp --mode=500 /opt/kibana && \
    set -o pipefail && \
    curl --speed-limit 256000 \
        "https://artifacts.elastic.co/downloads/kibana/kibana-${VERSION_KIBANA}-linux-x86_64.tar.gz" | \
        tar --extract --file=- --gzip --strip-components=1 --directory='/opt/kibana' && \
    chmod --recursive 'u=rwX,g=rX,o=rX' /opt/kibana && \
    install --directory --owner=contusr --group=contgrp --mode=700 /var/log/kibana


USER contusr
EXPOSE 5601/tcp
ENTRYPOINT ["/opt/kibana/bin/kibana"]
