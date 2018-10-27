FROM nfnty/arch-mini:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880049' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

COPY ["udp-broadcast-relay", "/opt/"]
RUN chmod 'u=rwX,g=rX,o=rX' /opt/udp-broadcast-relay && \
    setcap \
        'cap_net_bind_service,cap_net_raw=eip' /usr/bin/tini \
        'cap_net_bind_service,cap_net_raw=ei' /opt/udp-broadcast-relay

USER contusr
ENTRYPOINT ["/usr/bin/tini", "--", "/opt/udp-broadcast-relay"]
