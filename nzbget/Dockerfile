ARG BUILD_FROM
FROM $BUILD_FROM

# Install Bashio
ENV  BASHIO_VERSION=v0.13.1
RUN apk add --no-cache \
        jq=1.6-r1 \
    && curl -J -L -o /tmp/bashio.tar.gz \
        "https://github.com/hassio-addons/bashio/archive/$BASHIO_VERSION.tar.gz" \
    && mkdir /tmp/bashio \
    && tar zxvf \
        /tmp/bashio.tar.gz \
        --strip 1 -C /tmp/bashio \
    \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    \
    && rm -f -r \
        /tmp/*

# Configure NZBGet for Hass.io
RUN sed -i "s|/config|/data/config|g" /etc/services.d/nzbget/run \
    && sed -i "s|/config|/data/config|g" /etc/cont-init.d/30-config \
    && sed -i "s|/downloads|/share/nzbget/downloads|g" /etc/cont-init.d/30-config \
    && sed -i "s|/downloads|/share/nzbget/downloads|g" /app/nzbget/share/nzbget/nzbget.conf

# copy local files
COPY root/ /
