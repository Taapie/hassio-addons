FROM ubuntu:18.04

ENV GOLANG_VERSION 1.11
ENV PATH="/usr/local/go/bin:/usr/local/work/bin:${PATH}"

RUN apt-get update && \
    apt-get -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y wget git libc6-dev make pkg-config g++ \
                                           gcc mosquitto-clients mosquitto python3 python3-dev python3-pip \
                                           python3-setuptools python3-wheel supervisor dos2unix && \
    rm -rf /var/lib/apt/lists/*

RUN	dpkgArch="$(dpkg --print-architecture)" && \
	case "${dpkgArch##*-}" in \
		amd64)   goRelArch='linux-amd64'; \
		         goRelSha256='b3fcf280ff86558e0559e185b601c9eade0fd24c900b4c63cd14d1d38613e499' ;; \
		armhf)   goRelArch='linux-armv6l'; \
		         goRelSha256='8ffeb3577d8ca5477064f1cb8739835973c866487f2bf81df1227eaa96826acd' ;; \
		arm64)   goRelArch='linux-arm64'; \
		         goRelSha256='e4853168f41d0bea65e4d38f992a2d44b58552605f623640c5ead89d515c56c9' ;; \
		i386)    goRelArch='linux-386'; \
		         goRelSha256='1a91932b65b4af2f84ef2dce10d790e6a0d3d22c9ea1bdf3d8c4d9279dfa680e' ;; \
		ppc64el) goRelArch='linux-ppc64le'; \
		         goRelSha256='e874d617f0e322f8c2dda8c23ea3a2ea21d5dfe7177abb1f8b6a0ac7cd653272' ;; \
		s390x)   goRelArch='linux-s390x'; \
		         goRelSha256='c113495fbb175d6beb1b881750de1dd034c7ae8657c30b3de8808032c9af0a15' ;; \
		*)       echo >&2 "error: current architecture ($dpkgArch) is not supported"; \
		         exit 1 ;; \
	esac && \
    url="https://golang.org/dl/go${GOLANG_VERSION}.${goRelArch}.tar.gz" && \
	wget -nv -O go.tgz "$url" && \
	echo "${goRelSha256} *go.tgz" | sha256sum -c - && \
	tar -C /usr/local -xzf go.tgz && \
	rm go.tgz && \
	go version

RUN mkdir /usr/local/work && \
	mkdir /data && \
	mkdir /app && \
	mkdir /app/mosquitto_config && \
	touch /app/mosquitto_config/acl && \
	touch /app/mosquitto_config/passwd

RUN	mkdir /build && \
    cd /build && \
    git clone https://github.com/schollz/find3 && \
	cd /build/find3/server/main  && \
	go build -v && \
	mv /build/find3/server/main /app/main && \
	cd /build/find3/server/ai && \
	python3 -m pip install -r requirements.txt && \
	mv /build/find3/server/ai /app/ai

RUN	rm -rf /usr/local/work/src && \
	apt-get remove -y --auto-remove git libc6-dev pkg-config g++ gcc && \
	apt-get autoclean && \
	apt-get clean && \
	apt-get autoremove && \
	rm -rf ~/.local/share/Trash/* && \
	rm -rf /usr/local/go* && \
	rm -rf /usr/share/perl* && \
	rm -rf /build* && \
	rm -rf /usr/share/doc*

COPY files/startup.sh /app/startup.sh
COPY files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY files/mosquitto.conf /app/mosquitto_config/mosquitto.conf

RUN	chmod +x /app/startup.sh && \
    dos2unix /app/startup.sh && \
    dos2unix /etc/supervisor/conf.d/supervisord.conf && \
    dos2unix /app/mosquitto_config/mosquitto.conf

WORKDIR /app
CMD ["/app/startup.sh"]
