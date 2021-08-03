ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base-debian:buster
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base system
ARG BUILD_ARCH=amd64

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
               build-essential \
               git \
               pkg-config \
               wget 
               
# Install Go
ARG GO_VERSION=1.16

RUN ARCH="${BUILD_ARCH}" \
    && if [ "${BUILD_ARCH}" = "aarch64" ]; then ARCH="arm64"; fi \
    && if [ "${BUILD_ARCH}" = "armv7" ]; then ARCH="armv6l"; fi \
    && if [ "${BUILD_ARCH}" = "i386" ]; then ARCH="386"; fi \
    && GO_BUILD_FILE="go${GO_VERSION}.linux-${ARCH}.tar.gz" \
    && wget -nv https://dl.google.com/go/$GO_BUILD_FILE \
    && tar -C /usr/local -xzf $GO_BUILD_FILE

ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=$HOME/.go

# Install Rust
ARG RUST_VERSION=1.47

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup.sh \
    && chmod +x rustup.sh \
    && ./rustup.sh -y --default-toolchain $RUST_VERSION

# Clone influxdb
RUN git clone https://github.com/influxdata/influxdb.git

# Build influxdb
ARG INFLUXDB_VERSION=v2.0.7

RUN cd influxdb \
    && git checkout tags/$INFLUXDB_VERSION \
    && . $HOME/.cargo/env \
    && make

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Denis Taapken <dennis@lioncode.nl>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="Dennis Taapken <dennis@lioncode.nl>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://addons.community" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
