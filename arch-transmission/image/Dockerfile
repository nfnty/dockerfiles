FROM nfnty/arch-mini

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="100000"
ENV UGNAME="transmission"
ENV PRIMPATH="/transmission"
ENV TORRENTPATH="/torrent"

RUN groupadd --gid "$UGID" "$UGNAME" && \
    useradd --uid "$UGID" --gid "$UGID" --shell /usr/bin/false "$UGNAME"

RUN install --directory --owner=root --group=root --mode=755 "$PRIMPATH/scripts"
ADD scripts/completed_reflink.sh $PRIMPATH/scripts/
RUN chmod 755 "$PRIMPATH/scripts/completed_reflink.sh"

RUN install --directory --owner="$UGNAME" --group="$UGNAME" --mode=700 "$PRIMPATH/config"
ADD config/settings.json $PRIMPATH/config/
RUN chown "$UGNAME":"$UGNAME" "$PRIMPATH/config/settings.json" && \
    chmod 600 "$PRIMPATH/config/settings.json"
VOLUME ["$PRIMPATH/config"]

RUN install --directory --mode=755 --owner=root --group=root "$TORRENTPATH"
RUN install --directory --mode=700 --owner="$UGID" --group="$UGID" "$TORRENTPATH/"{completed,downloading,seeding}

ENV TMVERSION="1.8.4-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm transmission-cli && \
    pacman --sync --noconfirm --clean --clean

USER $UGNAME
EXPOSE 9091 51413
ENTRYPOINT ["/usr/bin/transmission-daemon", "--foreground", "--config-dir", "/transmission/config"]
