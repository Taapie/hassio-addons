ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

WORKDIR /data

# Install requirements for add-on
RUN apt-get update && \
    apt-get install -y --no-install-recommends git sudo iproute2 iputils-ping libssl-dev sed && \
    git clone https://github.com/ct-Open-Source/tuya-convert
#    git clone https://github.com/M4dmartig4n/tuya-convert
RUN cd tuya-convert && \
    git checkout tags/v2.4.1 && \
    # Fix range of dhcp to make sure devices get the 10.42.42.42 ip from dhcp
    sed -i 's|--dhcp-range=10.42.42.10,10.42.42.40,12h|--dhcp-range=10.42.42.42,10.42.42.42,10m|' scripts/setup_ap.sh && \
    sed -i 's|read -r||' start_flash.sh && \
    ./install_prereq.sh

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
