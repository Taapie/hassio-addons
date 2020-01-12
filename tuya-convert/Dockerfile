ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

WORKDIR /data

# Install requirements for add-on
RUN apt-get update && \
    apt-get install -y --no-install-recommends git sudo iproute2 iputils-ping && \
    git clone https://github.com/ct-Open-Source/tuya-convert 
RUN cd tuya-convert && \
    ./install_prereq.sh

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
