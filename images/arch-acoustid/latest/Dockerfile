FROM nfnty/arch-python2:latest
MAINTAINER nfnty <docker@nfnty.se>

RUN ugid='880037' && \
    groupadd --gid "${ugid}" contgrp && \
    useradd --uid "${ugid}" --gid "${ugid}" --shell /usr/bin/false contusr

ENV PATH="/opt/acoustid-server/e/bin:${PATH}" \
    PYTHONPATH="/opt/acoustid-server" \
    ACOUSTID_CONFIG="/opt/acoustid-server/acoustid.conf"
RUN pacman --sync --noconfirm --refresh --sysupgrade && \
    pacman --sync --noconfirm python nfnty/acoustid-server-git && \
    find /var/cache/pacman/pkg -mindepth 1 -delete

USER contusr
EXPOSE 5000/tcp
WORKDIR /opt/acoustid-server
ENTRYPOINT [ \
    "/opt/multiprocess.py", "--", \
    "/opt/acoustid-server/e/bin/python -m acoustid.web.app --host :: --api", \
    "/opt/acoustid-server/e/bin/python /opt/acoustid-server/scripts/import_submissions.py --config /opt/acoustid-server/acoustid.conf", \
    "/opt/acoustid-server/e/bin/python /opt/acoustid-server/scripts/warm_up_cache.py --config /opt/acoustid-server/acoustid.conf" \
]
