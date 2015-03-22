FROM nfnty/arch-mini

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="140000"
ENV UGNAME="fileshare"
ENV PRIMPATH="/samba"
ENV SHAREPATH="/share"

RUN install --directory --owner=root --group=root --mode=700 "$PRIMPATH/config" "$PRIMPATH/data/private"
ADD config/smb.conf $PRIMPATH/config/
RUN chmod 600 "$PRIMPATH/config/smb.conf"
VOLUME ["$PRIMPATH/data"]

RUN install --directory --owner=root --group=root --mode=755 "$SHAREPATH"

RUN groupadd --gid "$UGID" "$UGNAME" && \
    useradd --uid "$UGID" --gid "$UGID" --shell /usr/bin/false "$UGNAME"

ENV SAMBA_VERSION="4.2.0-1"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm samba && \
    pacman --sync --noconfirm --clean --clean

RUN rm --recursive '/var/lib/samba' && \
    ln --symbolic '/samba/data' '/var/lib/samba'

USER root
EXPOSE 139 445
ENTRYPOINT ["/usr/bin/smbd", "--foreground", "--log-stdout", "--configfile=/samba/config/smb.conf"]
