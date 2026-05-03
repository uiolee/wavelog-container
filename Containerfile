
ARG WAVELOG_GITSRC="https://github.com/wavelog/wavelog/archive/refs/tags"
ARG WAVELOG_GITTAG="2.4.1"
ARG APK_OPTS="--no-cache"

FROM alpine:latest AS base
ARG APK_OPTS

ENV LIGHTTPD_CONF="/etc/lighttpd/lighttpd.conf"

RUN \
    # --mount=type=bind,source=./repositories,target=/etc/apk/repositories \
    --mount=type=bind,source=./example,target=/temp \
    \
    apk ${APK_OPTS} add \
    php84-fpm \
    php84-session \
    php84-ctype \
    php84-simplexml \
    php84-curl \
    php84-mysqli \
    php84-mbstring \
    php84-xml \
    php84-zip \
    php84-gd \
    php84-apcu \
    lighttpd \
    tini \
    \
    && \
    addgroup -g 1000 -S wavelog && \
    adduser -H -h /wavelog/ -G wavelog -S -D -u 1000 wavelog && \
    addgroup lighttpd wavelog \
    \
    && \
    chmod 2770 /var/log/php84/ /var/log/lighttpd/ && \
    chown 1000:1000 /var/log/php84/ /var/log/lighttpd/ \
    \
    && \
    cp /temp/wavelog.lighttpd.conf $LIGHTTPD_CONF && \
    cp /temp/wavelog.phpfpm.conf /etc/php84/php-fpm.d/www.conf \
    \
    && \
    php-fpm84 -t && \
    echo 'Hello' && \
    lighttpd -t -f ${LIGHTTPD_CONF} && \
    lighttpd -tt -f ${LIGHTTPD_CONF} && \
    echo 'World!' && \
    rm -rf /var/log/php84/* && \
    rm -rf /var/log/lighttpd/* \
    \
    && \
    rm -rf \
    /etc/init.d \
    # /lib/apk \
    /var/log/apk.log \
    /var/www \
    && echo done

# COPY ./example/wavelog.lighttpd.conf $LIGHTTPD_CONF
# COPY ./example/wavelog.phpfpm.conf /etc/php84/php-fpm.d/www.conf

# ======================================
FROM base as dist
ARG WAVELOG_GITSRC
ARG WAVELOG_GITTAG
ARG CONFIG_DIR="/wavelog/config"

ENV LIGHTTPD_CONF="/etc/lighttpd/lighttpd.conf"

# COPY --chown=1000:1000 --chmod=2775 ./wavelog-${WAVELOG_GITTAG} /wavelog
# ADD --chown=1000:1000 --chmod=2775 https://github.com/wavelog/wavelog/archive/refs/tags/$WAVELOG_GITTAG.zip /wavelog
RUN \
    rm -rf /wavelog/ && echo '0' && \
    wget -O /tmp/tmp.zip $WAVELOG_GITSRC/$WAVELOG_GITTAG.zip && \
    unzip -o -q /tmp/tmp.zip -d /tmp/ && ls /tmp/ && \
    mv /tmp/wavelog-$WAVELOG_GITTAG/ /wavelog/ && \
    chown -R 1000:1000 /wavelog/ && \
    find /wavelog/ \
    \( -type d -exec chmod 2775 {} \; \) \
    -o \
    \( -type f -exec chmod 0664 {} \; \) && \
    rm -rf /tmp/tmp.zip

USER 1000:1000
RUN mkdir -p ${CONFIG_DIR} && \
    ln -s ${CONFIG_DIR}/config.php /wavelog/application/config/config.php && \
    ln -s ${CONFIG_DIR}/database.php /wavelog/application/config/database.php && \
    ln -s ${CONFIG_DIR}/memcached.php /wavelog/application/config/memcached.php && \
    ln -s ${CONFIG_DIR}/redis.php /wavelog/application/config/redis.php && \
    ln -s ${CONFIG_DIR}/sso.php /wavelog/application/config/sso.php && \
    chown -R 1000:1000 ${CONFIG_DIR}  && \
    chmod -R 2775 ${CONFIG_DIR}

USER 0:0
COPY --chown=0:0 --chmod=4755 ./sbin/entrypoint.sh /sbin/entrypoint.sh
WORKDIR /wavelog
ENTRYPOINT ["/sbin/tini"]
CMD ["-s", "-g", "--", "sh", "/sbin/entrypoint.sh"]

VOLUME [ "/wavelog/config", "/wavelog/uploads", "/wavelog/userdata", "/wavelog/updates" ]

EXPOSE 8080/tcp
HEALTHCHECK --interval=1m --timeout=15s --retries=10 \
    CMD wget -q -O - http://127.0.0.1:8080/index.php/cron/run || exit 1

LABEL \
    org.opencontainers.image.authors="uiolee" \
    org.opencontainers.image.description="Container Images of wavelog" \
    org.opencontainers.image.licenses="MPL-2.0" \
    org.opencontainers.image.source="https://github.com/uiolee/wavelog-container" \
    org.opencontainers.image.title="wavelog" \
    org.opencontainers.image.url="https://github.com/uiolee/wavelog-container" \
    org.opencontainers.image.version="${WAVELOG_GITTAG}-0.2" \
    wavelog.gittag="${WAVELOG_GITTAG}"
