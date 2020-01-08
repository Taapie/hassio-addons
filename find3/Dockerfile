ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Install requirements for add-on
RUN apk add --no-cache mosquitto-clients freetype libpng openblas python3 py3-pip && \
    apk add --no-cache --virtual .builddeps perl wget git pkgconfig build-base g++ gfortran linux-headers freetype-dev libpng-dev cython python3-dev py3-numpy-dev && \
    wget -q https://github.com/xianyi/OpenBLAS/archive/v0.3.6.tar.gz && \
    tar -xf v0.3.6.tar.gz && \
    cd OpenBLAS-0.3.6/ && \
    make BINARY=64 FC=$(which gfortran) USE_THREAD=1 && \
    make PREFIX=/usr install && \
    pip3 install scipy==1.1.0

# Get source code of Find3 including Go dependencies
ARG BUILD_VERSION
RUN git clone https://github.com/schollz/find3.git && \
    cd find3 && \
    git checkout $BUILD_VERSION 2> /dev/null && \
    go get -u -v . && \
    cd server/ai && \
    pip3 install -r requirements.txt
    #make && \
    #cd ../main && \
    #go build -v 

RUN apk del .builddeps && \
    rm -rf /root/.cache

WORKDIR /data

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
