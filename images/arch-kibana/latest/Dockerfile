FROM nfnty/arch-mini

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="120000"
ENV UGNAME="kibana"
ENV PRIMPATH="/kibana"

RUN groupadd --gid "$UGID" "$UGNAME" && \
    useradd --uid "$UGID" --gid "$UGID" --shell /usr/bin/false "$UGNAME"

RUN install --directory --mode=755 --owner=root --group=root "$PRIMPATH/"{bin,config}
ADD config/kibana.yml $PRIMPATH/config/
RUN chmod 644 "$PRIMPATH/config/"*

RUN pacman --sync --noconfirm util-linux && \
    pacman --sync --noconfirm --clean --clean

ENV KIBANA_VERSION="4.0.1"
RUN curl "https://download.elasticsearch.org/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x64.tar.gz" | \
    tar --extract --gzip --strip-components=1 --file=- --directory="$PRIMPATH/bin" --owner=root --group=root

RUN chmod --recursive o-w "$PRIMPATH/bin"
RUN rm --recursive "$PRIMPATH/bin/config" && \
    ln --symbolic "$PRIMPATH/config" "$PRIMPATH/bin/config"

USER $UGNAME
ENTRYPOINT ["/kibana/bin/bin/kibana"]
