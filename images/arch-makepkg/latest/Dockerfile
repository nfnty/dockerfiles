FROM nfnty/arch-mini:latest

MAINTAINER "nfnty <docker@nfnty.se>"

RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm base-devel git && \
    pacman --sync --noconfirm --clean --clean

ENV UGID="99999"
ENV UGNAME="makepkg"
ENV PRIMPATH="/makepkg"

RUN groupadd --gid "$UGID" "$UGNAME" && \
    useradd --uid "$UGID" --gid "$UGID" --shell /usr/bin/false "$UGNAME"

RUN install --directory --owner=root --group=root --mode=755 "$PRIMPATH/"{config,host/pkgbuild,scripts}
ADD scripts/makepkg.sh $PRIMPATH/scripts/
ADD config/makepkg.conf $PRIMPATH/config/
RUN chmod 755 "$PRIMPATH/scripts/makepkg.sh" && \
    chmod 644 "$PRIMPATH/config/makepkg.conf"

RUN install --directory --owner="$UGID" --group="$UGID" --mode=700 "$PRIMPATH/"{pkgbuild,builddir,pkgdest,srcdest,srcpkgdest,logs}
VOLUME ["$PRIMPATH/pkgdest", "$PRIMPATH/logs"]

ADD config/sudoers /etc/

USER $UGNAME
ENTRYPOINT ["/makepkg/scripts/makepkg.sh"]
