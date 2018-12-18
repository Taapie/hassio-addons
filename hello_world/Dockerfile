ARG BUILD_FROM=homeassistant/amd64-base:latest
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Install requirements
RUN apk add --no-cache python3

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

ENTRYPOINT [ "ls" ]
CMD ["-als"]