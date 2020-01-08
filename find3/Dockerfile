ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Install requirements for add-on
RUN apk add --no-cache python3 g++ mosquitto-clients git pkgconfig freetype-dev libpng-dev cython python3-dev && \
    pip install --upgrade pip && \
    pip install scipy

# Get source code of Find3 including Go dependencies
ARG BUILD_VERSION
RUN git clone https://github.com/schollz/find3.git && \
    cd find3 && \
    git checkout $BUILD_VERSION 2> /dev/null && \
    go get -u -v . && \
    cd server/ai && \
    python3 -m pip install -r requirements.txt && \
    make && \
    cd ../main && \
    go build -v 

WORKDIR /data

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
