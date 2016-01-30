FROM scratch
MAINTAINER nfnty <docker@nfnty.se>

ADD ["bootstrap/arch-mini-bootstrap.tar.xz", "/"]

ENV PATH='/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl' \
    LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_CTYPE='en_US.UTF-8' \
    LC_NUMERIC='en_US.UTF-8' \
    LC_TIME='en_DK.UTF-8' \
    LC_COLLATE='en_US.UTF-8' \
    LC_MONETARY='en_US.UTF-8' \
    LC_MESSAGES='en_US.UTF-8' \
    LC_PAPER='en_DK.UTF-8' \
    LC_NAME='en_US.UTF-8' \
    LC_ADDRESS='en_US.UTF-8' \
    LC_TELEPHONE='en_US.UTF-8' \
    LC_MEASUREMENT='en_DK.UTF-8' \
    LC_IDENTIFICATION='en_US.UTF-8' \
    TZ='UTC'

COPY ["etc/", "/etc/"]
COPY ["crypto/", "/tmp/crypto/"]
RUN locale-gen && \

    chmod 'u=rwX,g=rX,o=rX' /etc/{locale.conf,locale.gen,pacman.conf,pacman.d,pacman.d/mirrorlist} && \

    ln --symbolic "/usr/share/zoneinfo/${TZ}" /etc/localtime && \

    pacman-key --init && \
    pacman-key --populate archlinux && \

    find /tmp/crypto/ca-certificates -type f -not -name '.gitignore' \
        -exec install --owner=root --group=root --mode=755 \
            --target-directory='/etc/ca-certificates/trust-source/anchors' '{}' '+' && \
    update-ca-trust && \

    find /tmp/crypto/pacman/keys -type f -not -name '.gitignore' -exec pacman-key --add '{}' '+' && \
    find /tmp/crypto/pacman/trust -type f -not -name '.gitignore' \
        -exec gpg --homedir /etc/pacman.d/gnupg --import-ownertrust '{}' '+' && \

    rm --recursive /tmp/crypto && \

    pacman --sync --noconfirm --refresh --sysupgrade && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

CMD ["/usr/bin/bash"]
