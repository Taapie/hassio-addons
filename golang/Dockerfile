ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Install Golang
ARG BUILD_VERSION
ARG BUILD_ARCH

ENV GOLANG_VERSION $BUILD_VERSION
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GO111MODULE=on

WORKDIR /data

RUN apk add --no-cache --virtual .builddeps wget
RUN case "${BUILD_ARCH}" in \
         amd64) goArch='amd64'; goRelArch='linux-amd64'; goRelSha256='a1bc06deb070155c4f67c579f896a45eeda5a8fa54f35ba233304074c4abbbbd'; ;; \
         armhf) goArch='arm'; goRelArch='linux-armv6l'; goRelSha256='37a1a83e363dcf146a67fa839d170fd1afb13009585fdd493d0a3370fbe6f785'; ;; \
         armv7) goArch='arm'; goRelArch='linux-armv6l'; goRelSha256='37a1a83e363dcf146a67fa839d170fd1afb13009585fdd493d0a3370fbe6f785'; ;; \
         aarch64) goArch='arm64'; goRelArch='linux-arm64'; goRelSha256='0a18125c4ed80f9c3045cf92384670907c4796b43ed63c4307210fe93e5bbca5'; ;; \
         i386) goArch='386'; goRelArch='linux-386'; goRelSha256='27feb013106da784f09e560720aa41ab395c67f7eed4c4a0fce04bc6e3d01c7d'; ;; \
         *) echo  "warning: current architecture ($BUILD_ARCH) does not have a corresponding Go binary release"; exit 1 ;; \
    esac && \
    wget -q -O go.tgz "https://golang.org/dl/go${GOLANG_VERSION}.${goRelArch}.tar.gz" && \
    echo "${goRelSha256} *go.tgz" | sha256sum -c - && \
    echo $goArch > go_arch && \
    tar -C /usr/local -xzf go.tgz  &&\
    rm go.tgz 

#RUN apk del .builddeps && \
#    rm -rf /var/lib/apt/lists/* && \
#    rm -rf /root/.cache

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]


