FROM nfnty/arch-jre8:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880004' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV VERSION_UNIFI='5.9.29' JAVA_HOME='/usr/lib/jvm/default-runtime'
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm mongodb && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    \
    mkdir /opt/unifi && \
    set -o pipefail && \
    curl --speed-limit 256000 --location \
        "https://dl.ubnt.com/unifi/${VERSION_UNIFI}/UniFi.unix.zip" | \
        bsdtar --extract --file=- --strip-components=1 --no-same-owner --directory='/opt/unifi' && \
    rm --recursive /opt/unifi/lib/native && \
    curl 'http://central.maven.org/maven2/org/xerial/snappy/snappy-java/1.1.2.6/snappy-java-1.1.2.6.jar' --output /opt/unifi/lib/snappy-java-*
COPY ["mongod", "/opt/unifi/bin/"]
RUN chmod --recursive 'u=rwX,g=rX,o=rX' /opt/unifi && \
    install --directory --owner=contusr --group=contgrp --mode=700 /opt/unifi/{data,logs,run,work}

USER contusr
VOLUME ["/opt/unifi/data", "/opt/unifi/logs", "/opt/unifi/work"]
EXPOSE 8080/tcp 8443/tcp
WORKDIR /opt/unifi
ENTRYPOINT ["/usr/bin/java", "-jar", "/opt/unifi/lib/ace.jar", "start"]
