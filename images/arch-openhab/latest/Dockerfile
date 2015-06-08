FROM nfnty/arch-java:jre8-openjdk-headless

MAINTAINER nfnty <docker@nfnty.se>

ENV UGID="170000" UGNAME="openhab" PRIMPATH="/openhab"

ENV JAVA_HOME="/usr/lib/jvm/default-runtime"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=500 \
        "${PRIMPATH}/"{,addons,bin,config,scripts,state,webapps} && \
    install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{data,log,tmp,work} && \
    rmdir /tmp && \
    ln --symbolic "${PRIMPATH}/tmp" /tmp
VOLUME ["${PRIMPATH}/data", "${PRIMPATH}/log", "${PRIMPATH}/state", "${PRIMPATH}/tmp", "${PRIMPATH}/work"]

ADD scripts/start.sh ${PRIMPATH}/scripts/
RUN chown "${UGNAME}:${UGNAME}" "${PRIMPATH}/scripts/start.sh" && \
    chmod 'u=rX,g=,o=' "${PRIMPATH}/scripts/start.sh"

RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm unzip telldus-core-git ttf-dejavu && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    rm /etc/tellstick.conf && \
    ln --symbolic "${PRIMPATH}/config/tellstick.conf" /etc/tellstick.conf && \
    install --owner="${UGNAME}" --group="${UGNAME}" --mode=600 /var/state/telldus-core.conf "${PRIMPATH}/state/" && \
    rm --recursive /var/state && \
    ln --symbolic "${PRIMPATH}/state" /var/state

ENV OPENHAB_VERSION="1.7.0"
RUN curl --location --output /tmp/openhab-runtime.zip \
    "https://bintray.com/artifact/download/openhab/bin/distribution-${OPENHAB_VERSION}-runtime.zip" && \
    unzip /tmp/openhab-runtime.zip -d "${PRIMPATH}/bin" && \
    rm /tmp/openhab-runtime.zip && \
    chown --recursive "${UGNAME}:${UGNAME}" "${PRIMPATH}/bin" && \
    chmod --recursive 'u=rX,g=,o=' "${PRIMPATH}/bin" && \
    rm --recursive "${PRIMPATH}/bin/"{addons,configurations,webapps} && \
    ln --symbolic "${PRIMPATH}/addons" "${PRIMPATH}/bin/addons" && \
    ln --symbolic "${PRIMPATH}/config" "${PRIMPATH}/bin/configurations" && \
    ln --symbolic "${PRIMPATH}/log" "${PRIMPATH}/bin/logs" && \
    ln --symbolic "${PRIMPATH}/webapps" "${PRIMPATH}/bin/webapps"

USER ${UGNAME}
EXPOSE 8080/tcp 8443/tcp
ENTRYPOINT ["/openhab/scripts/start.sh"]
