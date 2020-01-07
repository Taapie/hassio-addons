ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Install requirements for add-on
RUN apk add --no-cache python3 go g++ mosquitto-clients git

# Get source code of Find3 including Go dependencies
ARG BUILD_VERSION
RUN git clone https://github.com/schollz/find3.git && \
    cd find3 && \
    git checkout $BUILD_VERSION 2> /dev/null

RUN cd find3 && \
    go get -u -v .

RUN apk add --no-cache pkgconfig freetype-dev libpng-dev

RUN apk add --no-cache cython
RUN apk add --no-cache python3-dev

RUN cd find3/server/ai && \
    python3 -m pip install -r requirements.txt

RUN cd find3/server/ai && \
    make

RUN cd find3/server/main && \
    go build -v 

WORKDIR /data

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
