ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_VERSION
ARG BUILD_ARCH

ENV LANG C.UTF-8

ENV GOLANG_VERSION 1.11.4

ENV GOLANG_BASE_PATH="/usr/local"
ENV GOLANG_DIR_NAME="go"
ENV GOLANG_PATH="$GOLANG_BASE_PATH/$GOLANG_DIR_NAME"

ENV GOPATH="/go"

ENV PATH="$GOPATH/bin:$GOLANG_PATH/bin:${PATH}"

# The following builds Golang
RUN apk add --no-cache --virtual .build-go-deps \
        bash \
        gcc \
        musl-dev \
        openssl \
	    go \
	    curl \
	    tar \
 && export \
		GOROOT_BOOTSTRAP="$(go env GOROOT)" \
		GOOS="$(go env GOOS)" \
		GOARCH="$(go env GOARCH)" \
		GOHOSTOS="$(go env GOHOSTOS)" \
		GOHOSTARCH="$(go env GOHOSTARCH)" \
 && apkArch="$(apk --print-arch)" \
 &&	case "$apkArch" in \
		armhf) export GOARM='6' ;; \
		x86)   export GO386='387' ;; \
	esac \
 && go_url="https://golang.org/dl/go${GOLANG_VERSION}.src.tar.gz" \
 &&	curl --silent --show-error --fail --location \
         --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" \
         -o - "$go_url" \
    | tar --no-same-owner -C "$GOLANG_BASE_PATH" -xz "$GOLANG_DIR_NAME" \
 && cd "$GOLANG_PATH/src" \
 && ./make.bash \
 && rm -rf "$GOLANG_PATH/pkg/bootstrap" "$GOLANG_PATH/pkg/obj" \
 && apk del .build-go-deps \
 && mkdir -p "$GOPATH/src" "$GOPATH/bin" \
 && chmod -R 777 "$GOPATH" \
 && go version

# The following builds Find3
RUN apk add --no-cache \
        git \
        python3 \
        g++ \
        mosquitto-clients \
 && python3 -m ensurepip \
 && rm -r /usr/lib/python*/ensurepip \
 && pip3 install --upgrade pip setuptools

RUN go get -u -v github.com/schollz/find3/server/...

RUN apk add --no-cache \
        freetype-dev \
        libpng-dev \
        lapack-dev \
        python3-dev \
        gfortran \
 && cd $GOPATH/src/github.com/schollz/find3/server/ai \
 && python3 -m pip install numpy==1.15.1 scipy==1.1.0

RUN cd $GOPATH/src/github.com/schollz/find3/server/ai \
 && python3 -m pip install -r requirements.txt

RUN apk add --no-cache \
        make

RUN cd $GOPATH/src/github.com/schollz/find3/server/main \
 && go build -v

RUN apk add --no-cache \
        supervisor

#RUN apk add --no-cache --virtual .build-find3-deps \
#        git \
#        make \
#        libc-dev \
#        pkgconfig \
#        g++ \
#        gcc \
#        freetype-dev \
#        libpng \
#        python3-dev \
# && apk add --no-cache \
#        mosquitto-clients \
#        python3 \
# && python3 -m ensurepip \
# && rm -r /usr/lib/python*/ensurepip \
# && pip3 install --upgrade pip setuptools \
# && mkdir /build \
# && cd /build  \
# && git clone https://github.com/schollz/find3 \
# && cd /build/find3/server/main \
# &&	go build -v \
# && mkdir /app \
# &&	mv /build/find3/server/main /app/main
#
#RUN cd /build/find3/server/ai \
# && python3 -m pip install -r requirements.txt \
# && mv /build/find3/server/ai /app/ai \
# && apk del .build-find3-deps

# The following installs the tools to run Find3
#RUN apk add --no-cache \
#        supervisor

#RUN mkdir /usr/local/work && \
#	mkdir /data && \

#RUN	rm -rf /usr/local/work/src && \
#	rm -rf ~/.local/share/Trash/* && \
#	rm -rf /usr/local/go* && \
#	rm -rf /usr/share/perl* && \
#	rm -rf /build* && \
#	rm -rf /usr/share/doc*

COPY run.sh /
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN	chmod a+x /run.sh
# && dos2unix -c 7bit /run.sh \
# && dos2unix /etc/supervisor/conf.d/supervisord.conf

ENTRYPOINT ["/bin/bash", "-c", "echo hello"]
CMD [""]
