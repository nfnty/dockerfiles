FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='120000' UGNAME='kibana'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV KIBANA_VERSION='4.2.0' BABEL_CACHE_PATH='/tmp/babel.json'
RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=500 /opt/kibana && \
    curl "https://download.elastic.co/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x64.tar.gz" | \
        tar --extract --gzip --strip-components=1 --file=- --directory='/opt/kibana' && \
    chmod --recursive 'u=rwX,g=rX,o=rX' "/opt/kibana" && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 /var/log/kibana

USER ${UGNAME}
VOLUME ["/var/log/kibana"]
EXPOSE 5601/tcp
ENTRYPOINT ["/opt/kibana/bin/kibana"]
