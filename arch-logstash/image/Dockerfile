FROM nfnty/arch-java:jre8-openjdk-headless

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="130000"
ENV UGNAME="logstash"
ENV PRIMPATH="/logstash"
ENV JAVA_HOME="/usr/lib/jvm/default-runtime"
ENV SINCEDB_PATH="$PRIMPATH/data/sincedb/default"

RUN groupadd --gid "$UGID" "$UGNAME" && \
    useradd --uid "$UGID" --gid "$UGID" --shell /usr/bin/false "$UGNAME"

RUN install --directory --mode=755 --owner=root --group=root "$PRIMPATH/"{bin,config,host}
ADD config/test.conf $PRIMPATH/config/
RUN chmod 644 "$PRIMPATH/config/"*
RUN install --directory --mode=700 --owner="$UGID" --group="$UGID" "$PRIMPATH/"{bundle,data/sincedb}
VOLUME ["$PRIMPATH/data"]

ENV LSVERSION="1.5.0.rc2"
RUN curl "https://download.elasticsearch.org/logstash/logstash/logstash-${LSVERSION}.tar.gz" | \
    tar --extract --gzip --strip-components=1 --file=- --directory="$PRIMPATH/bin" --owner=root --group=root

RUN chmod --recursive o-w "$PRIMPATH/bin"
RUN ln --symbolic "$PRIMPATH/bundle" "$PRIMPATH/bin/.bundle"

USER $UGNAME
ENTRYPOINT ["/logstash/bin/bin/logstash", "--config", "/logstash/config"]
