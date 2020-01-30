ARG BUILD_FROM
FROM $BUILD_FROM

USER root:root

ENV LEGO_PATH=/var/lib/lego

ARG LEGO_TREEISH=v3.3.0
ARG LEGO_REMOTE=https://github.com/go-acme/lego.git
ARG LEGO_USER_UID=1000
ARG LEGO_USER_GID=1000

RUN apk add --no-cache --virtual .builddeps git gcc alpine-sdk

WORKDIR /data
RUN git clone "${LEGO_REMOTE:?}" lego \
    && cd lego \
    && git checkout "${LEGO_TREEISH:?}" \
    && git submodule update --init --recursive \
    && go build -o ./dist/lego -ldflags "-s -w -X main.version=${LEGO_TREEISH:?}" ./cmd/lego/main.go \
    && mv ./dist/lego /usr/bin/lego \
    && cd .. \
    && rm -rf lego \
    && groupadd --gid "${LEGO_USER_GID:?}" lego \
    && useradd --uid "${LEGO_USER_UID:?}" --gid "${LEGO_USER_GID:?}" --shell "$(command -v bash)" \
               --home-dir /home/lego/ --create-home lego \
    && mkdir -p "${LEGO_PATH:?}" \
    && chown lego:lego "${LEGO_PATH:?}" \
    && chmod 700 "${LEGO_PATH:?}"

RUN apk del .builddeps && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache

COPY run.sh /

USER lego:lego

WORKDIR $LEGO_PATH
ENTRYPOINT [ "/run.sh" ]
