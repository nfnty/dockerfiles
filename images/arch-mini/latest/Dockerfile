FROM scratch

MAINTAINER "nfnty <docker@nfnty.se>"

ADD bootstrap/arch-mini-bootstrap_2015-04-08.tar.xz /

ADD config/mirrorlist /etc/pacman.d/
ADD config/locale.conf config/pacman.conf /etc/
RUN chown 'root:root' /etc/{pacman.d/mirrorlist,locale.conf,pacman.conf} && \
    chmod 'u=rwX,g=rX,o=rX' /etc/{pacman.d/mirrorlist,locale.conf,pacman.conf}

RUN ln --symbolic /usr/share/zoneinfo/UTC /etc/localtime && \
    localedef --inputfile=en_US --charmap=UTF-8 en_US.UTF-8 && \
    localedef --inputfile=en_DK --charmap=UTF-8 en_DK.UTF-8

RUN pacman-key --init && \
    pacman-key --populate archlinux

ADD crypto/ca-certificates/ /tmp/ca-certificates/
RUN find /tmp/ca-certificates -mindepth 1 -type f -not -path '*/.gitignore' \
        -exec cp --target-directory='/etc/ca-certificates/trust-source/anchors' '{}' '+' && \
    rm --recursive /tmp/ca-certificates && \
    chown --recursive 'root:root' /etc/ca-certificates/trust-source/anchors && \
    chmod --recursive 'u=rwX,g=rX,o=rX' /etc/ca-certificates/trust-source/anchors && \
    setfattr --name=user.pax.flags --value=E /usr/bin/trust && \
    trust extract-compat

ADD crypto/gnupg/ /tmp/gnupg/
RUN find /tmp/gnupg/keys -mindepth 1 -type f -not -path '*/.gitignore' \
        -exec pacman-key --add '{}' '+' && \
    find /tmp/gnupg/trust -mindepth 1 -type f -not -path '*/.gitignore' \
        -exec gpg --homedir /etc/pacman.d/gnupg --import-ownertrust '{}' '+' && \
    rm --recursive /tmp/gnupg

RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm --clean --clean

CMD ["/usr/bin/bash"]
