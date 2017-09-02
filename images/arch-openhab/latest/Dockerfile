FROM nfnty/arch-jre8:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880017' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_OPENHAB='1.8.3' JAVA_HOME='/usr/lib/jvm/default-runtime'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm ttf-dejavu && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    \
    mkdir /opt/openhab && \
    set -o pipefail && \
    curl --speed-limit 256000 --location \
        "https://bintray.com/artifact/download/openhab/bin/distribution-${VERSION_OPENHAB}-runtime.zip" | \
        bsdtar --extract --file=- --directory='/opt/openhab' && \
    chmod --recursive 'u=rwX,g=rX,o=rX' /opt/openhab && \
    chmod --recursive 755 /opt/openhab/{start.sh,start_debug.sh} && \
    chown --recursive contusr:contgrp /opt/openhab/webapps/static && \
    \
    perl -p -i \
        -e 's|^(java \\)|exec \1|;' \
        -e 's|(-console)|-configuration /var/lib/openhab/work \\\n\t\1|;' \
        -e 's|(-console)|-data /var/lib/openhab/work \\\n\t\1|;' \
        -e 's|(-Djetty\.port=)|-Dsmarthome.userdata=/var/lib/openhab \\\n\t\1|;' \
        /opt/openhab/{start.sh,start_debug.sh} && \
    perl -0777 -p -i -e 's|( *)(<Ref id="RequestLog">.*</Ref>)|\1<!--\n\1\2\n\1-->|s' /opt/openhab/etc/jetty.xml && \
    install --directory --owner=contusr --group=contgrp --mode=700 \
        /var/lib/openhab{,/work} /var/log/openhab

USER contusr
VOLUME ["/var/lib/openhab"]
EXPOSE 8080/tcp 8443/tcp
ENTRYPOINT ["/opt/openhab/start.sh"]
