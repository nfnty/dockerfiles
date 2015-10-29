FROM nfnty/arch-jre8:latest
MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="170000" UGNAME="openhab"
RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

ENV OPENHAB_VERSION="1.7.1" JAVA_HOME="/usr/lib/jvm/default-runtime"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm unzip telldus-core-git ttf-dejavu && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \

    mkdir /opt/openhab && \
    curl --location --output /tmp/openhab-runtime.zip \
    "https://bintray.com/artifact/download/openhab/bin/distribution-${OPENHAB_VERSION}-runtime.zip" && \
    unzip /tmp/openhab-runtime.zip -d /opt/openhab && \
    rm /tmp/openhab-runtime.zip && \
    chown --recursive "${UGNAME}:${UGNAME}" /opt/openhab && \
    chmod --recursive 'u=rX,g=,o=' /opt/openhab  && \
    sed --in-place \
        --expression='s|^java|exec java|' \
        --expression='s|-console|-configuration /var/lib/openhab/work \\\n\t-data /var/lib/openhab/work \\\n\t-console|' \
        --expression='s|-Djetty\.port=|-Dsmarthome.userdata=/var/lib/openhab \\\n\t-Dopenhab.logdir=/var/log/openhab \\\n\t-Djetty\.port=|' \
        --expression='s|-Djetty\.port=|-Djetty.logs=/var/log/openhab \\\n\t-Djetty\.port=|' \
        /opt/openhab/{start.sh,start_debug.sh} && \

    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        /var/lib/openhab /var/log/openhab
VOLUME ["/var/lib/openhab", "/var/lib/telldus", "/var/log/openhab"]

USER ${UGNAME}
EXPOSE 8080/tcp 8443/tcp
ENTRYPOINT ["/usr/bin/bash", "-c", "/usr/bin/telldusd --nodaemon & exec /opt/openhab/start.sh"]
