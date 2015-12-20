FROM nfnty/arch-jre8:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID='170000' UGNAME='openhab'
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV OPENHAB_VERSION='1.7.1' JAVA_HOME='/usr/lib/jvm/default-runtime'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm ttf-dejavu && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \

    mkdir /opt/openhab && \
    curl --speed-limit 256000 --location \
        "https://bintray.com/artifact/download/openhab/bin/distribution-${OPENHAB_VERSION}-runtime.zip" | \
        bsdtar --extract --file=- --directory='/opt/openhab' && \
    chmod --recursive 'u=rwX,g=rX,o=rX' /opt/openhab && \
    chmod --recursive 755 /opt/openhab/{start.sh,start_debug.sh} && \
    chown --recursive "${UGNAME}:${UGNAME}" /opt/openhab/webapps/static && \

    sed --in-place --regexp-extended \
        --expression='s|^(java \\)|exec \1|' \
        --expression='s|(-console)|-configuration /var/lib/openhab/work \\\n\t\1|' \
        --expression='s|(-console)|-data /var/lib/openhab/work \\\n\t\1|' \
        --expression='s|(-Djetty\.port=)|-Dsmarthome.userdata=/var/lib/openhab \\\n\t\1|' \
        --expression='s|(-Djetty\.port=)|-Dopenhab.logdir=/var/log/openhab \\\n\t\1|' \
        --expression='s|(-Djetty\.port=)|-Djetty.logs=/var/log/openhab \\\n\t\1|' \
        /opt/openhab/{start.sh,start_debug.sh} && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        /var/lib/openhab{,/work} /var/log/openhab

USER ${UGNAME}
VOLUME ["/var/lib/openhab", "/var/log/openhab"]
EXPOSE 8080/tcp 8443/tcp
ENTRYPOINT ["/opt/openhab/start.sh"]
