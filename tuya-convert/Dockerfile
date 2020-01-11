ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

WORKDIR /data

# Install requirements for add-on
RUN git clone https://github.com/ct-Open-Source/tuya-convert && \
    cd tuya-convert && \
    ./install_preqreq.sh

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
