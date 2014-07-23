FROM nfnty/arch-mini

RUN update-ca-certificates
RUN pacman -Syu --noconfirm
RUN pacman -S --needed --noconfirm base-devel
RUN pacman -D --asexplicit $(pacman -Sgq base-devel)

RUN mkdir -p /srv/builder/makepkg
RUN mkdir /srv/scripts

RUN useradd -d /srv/builder builder
RUN chown -R builder:builder /srv/builder

COPY etc /etc/
COPY build.sh /srv/scripts/

USER builder
WORKDIR /srv/builder/makepkg
ENV PKGDEST /srv/builder/pkg
ENTRYPOINT ["/srv/scripts/build.sh"]
