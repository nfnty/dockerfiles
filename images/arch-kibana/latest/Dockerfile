FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='120000' UGNAME='kibana'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV VERSION_KIBANA='4.6.1' BABEL_CACHE_PATH='/tmp/babel.json'
RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=500 /opt/kibana && \
    set -o pipefail && \
    curl --speed-limit 256000 \
        "https://download.elastic.co/kibana/kibana/kibana-${VERSION_KIBANA}-linux-x86_64.tar.gz" | \
        tar --extract --file=- --gzip --strip-components=1 --directory='/opt/kibana' && \
    chmod --recursive 'u=rwX,g=rX,o=rX' /opt/kibana && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 /var/log/kibana


USER ${UGNAME}
EXPOSE 5601/tcp
ENTRYPOINT ["/usr/bin/tini", "--", "/opt/kibana/bin/kibana"]
