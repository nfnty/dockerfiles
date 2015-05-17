FROM nfnty/arch-java:jre8-openjdk-headless

MAINTAINER "nfnty <docker@nfnty.se>"

ENV UGID="170000" UGNAME="openhab" PRIMPATH="/openhab"

ENV JAVA_HOME="/usr/lib/jvm/default-runtime"

RUN groupadd --gid "${UGID}" "${UGNAME}" && \
    useradd --uid "${UGID}" --gid "${UGID}" --shell /usr/bin/false "${UGNAME}"

RUN install --directory --owner=root --group="${UGNAME}" --mode=750 \
        "${PRIMPATH}/"{,addons,bin,config,scripts,webapps}
ADD config/ ${PRIMPATH}/config/
ADD scripts/ ${PRIMPATH}/scripts/
RUN chown --recursive "root:${UGNAME}" "${PRIMPATH}/"{config,scripts} && \
    chmod --recursive 'u=rwX,g=rX,o=' "${PRIMPATH}/"{config,scripts}

RUN install --directory --owner="${UGNAME}" --group="${UGNAME}" --mode=700 \
        "${PRIMPATH}/"{data,logs,tmp,work} && \
    rmdir /tmp && \
    ln --symbolic "${PRIMPATH}/tmp" /tmp
VOLUME ["${PRIMPATH}/data", "${PRIMPATH}/logs", "${PRIMPATH}/work", "${PRIMPATH}/tmp"]

RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm unzip telldus-core-git ttf-dejavu && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    rm /etc/tellstick.conf && \
    ln --symbolic "${PRIMPATH}/config/tellstick.conf" /etc/tellstick.conf && \
    mv /var/state "${PRIMPATH}/state" && \
    ln --symbolic "${PRIMPATH}/state" /var/state
VOLUME ["${PRIMPATH}/state"]

ENV OPENHAB_VERSION="1.6.2"
RUN curl --location --output /tmp/openhab-runtime.zip \
    "https://github.com/openhab/openhab/releases/download/v${OPENHAB_VERSION}/distribution-${OPENHAB_VERSION}-runtime.zip" && \
    unzip /tmp/openhab-runtime.zip -d "${PRIMPATH}/bin" && \
    rm /tmp/openhab-runtime.zip && \
    chown --recursive "root:${UGNAME}" "${PRIMPATH}/bin" && \
    chmod --recursive 'u=rwX,g=rX,o=' "${PRIMPATH}/bin" && \
    rm --recursive "${PRIMPATH}/bin/"{addons,configurations,webapps} && \
    ln --symbolic "${PRIMPATH}/addons" "${PRIMPATH}/bin/addons" && \
    ln --symbolic "${PRIMPATH}/config" "${PRIMPATH}/bin/configurations" && \
    ln --symbolic "${PRIMPATH}/logs" "${PRIMPATH}/bin/logs" && \
    ln --symbolic "${PRIMPATH}/webapps" "${PRIMPATH}/bin/webapps"

USER ${UGNAME}
EXPOSE 8080 8443 5555 9001
ENTRYPOINT ["/openhab/scripts/start.sh"]
