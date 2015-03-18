FROM nfnty/arch-java:jre8-openjdk-headless

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="110000"
ENV UGNAME="elasticsearch"
ENV PRIMPATH="/elasticsearch"
ENV JAVA_HOME="/usr/lib/jvm/default-runtime"

RUN groupadd --gid "$UGID" "$UGNAME" && \
    useradd --uid "$UGID" --gid "$UGID" --shell /usr/bin/false "$UGNAME"

RUN install --directory --mode=755 --owner=root --group=root "$PRIMPATH/"{bin,config}
ADD config/elasticsearch.yml config/logging.yml $PRIMPATH/config/
RUN chmod 644 "$PRIMPATH/config/"*
RUN install --directory --mode=700 --owner="$UGID" --group="$UGID" "$PRIMPATH/"{data,logs,work,plugins}
VOLUME ["$PRIMPATH/data", "$PRIMPATH/logs"]

RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm util-linux && \
    pacman --sync --noconfirm --clean --clean

ENV ESVERSION="1.4.4"
RUN curl "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${ESVERSION}.tar.gz" | \
    tar --extract --gzip --strip-components=1 --file=- --directory="$PRIMPATH/bin" --owner=root --group=root

RUN chmod --recursive o-w "$PRIMPATH/bin"
RUN rm --recursive "$PRIMPATH/bin/config" && \
    ln --symbolic "$PRIMPATH/config" "$PRIMPATH/bin/config"

USER $UGNAME
EXPOSE 9200 9300
ENTRYPOINT ["/elasticsearch/bin/bin/elasticsearch"]
