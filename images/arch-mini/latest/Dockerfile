FROM scratch
MAINTAINER nfnty <docker@nfnty.se>

ADD ["bootstrap/arch-mini-bootstrap.tar.xz", "/"]

ENV PATH='/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl' \
    LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_TIME='en_DK.UTF-8' \
    LC_PAPER='en_DK.UTF-8' \
    LC_MEASUREMENT='en_DK.UTF-8' \
    TZ='UTC'

COPY ["crypto/", "/tmp/crypto/"]
COPY ["etc/", "/etc/"]
COPY ["opt/", "/opt/"]
COPY ["packages/", "/tmp/packages/"]
RUN locale-gen && \
    \
    chmod 'u=rwX,g=rX,o=rX' \
        /etc/{locale.conf,locale.gen,pacman.conf,pacman.d,pacman.d/mirrorlist} \
        /opt/multiprocess.py && \
    \
    ln --symbolic "/usr/share/zoneinfo/${TZ}" /etc/localtime && \
    \
    pacman-key --init && \
    pacman-key --populate archlinux && \
    \
    find /tmp/crypto/ca-certificates -type f -not -name '.gitignore' \
        -exec install --owner=root --group=root --mode=755 \
            --target-directory='/etc/ca-certificates/trust-source/anchors' '{}' '+' && \
    update-ca-trust && \
    \
    find /tmp/crypto/pacman/keys -type f -not -name '.gitignore' -exec pacman-key --add '{}' '+' && \
    find /tmp/crypto/pacman/trust -type f -not -name '.gitignore' \
        -exec gpg --homedir /etc/pacman.d/gnupg --import-ownertrust '{}' '+' && \
    \
    rm --recursive /tmp/crypto && \
    \
    pacman --sync --noconfirm --refresh --sysupgrade && \
    find /tmp/packages -type f -not -name '.gitignore' -and -not -name '*.sig' -exec pacman --upgrade --noconfirm '{}' '+' && \
    rm --recursive /tmp/packages && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

CMD ["/usr/bin/bash"]
