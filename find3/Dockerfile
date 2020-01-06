FROM jarleh/find3:latest

USER root:root

RUN export DEBIAN_FRONTEND=noninteractive \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
                jq \
	&& rm -rf /var/lib/apt/lists/*

COPY run.sh /

WORKDIR /
ENTRYPOINT [ "/run.sh" ]
