FROM arch-mini

RUN update-ca-certificates
RUN pacman -Syu --noconfirm
RUN pacman -S --needed --noconfirm base-devel
RUN pacman -D --asexplicit $(pacman -Sgq base-devel)

RUN mkdir -p /home/builder/makepkg
RUN mkdir /home/builder/pkg
RUN useradd -d /home/builder builder
COPY etc /etc/

WORKDIR /home/builder/makepkg
ENV PKGDEST /home/builder/pkg
CMD ["/usr/bin/makepkg", "-s", "--noconfirm" ]

COPY makepkg /home/builder/makepkg/
RUN chown -R builder:builder /home/builder
USER builder
