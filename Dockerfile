FROM adoptopenjdk:16-jre-hotspot-focal AS builder
MAINTAINER Ingo Müller <ingo.mueller@inf.ethz.ch>

# Tools for building
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        unzip \
        wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and unpack
RUN cd /opt/ && \
    wget --progress=dot:giga -O asterix-server.zip \
        https://downloads.apache.org/asterixdb/asterixdb-0.9.6/asterix-server-0.9.6-binary-assembly.zip && \
    unzip asterix-server.zip && \
    mv apache-asterixdb-0.9.6 asterixdb

FROM adoptopenjdk:16-jre-hotspot-focal

# Runtime depencensies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        procps \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/asterixdb /opt/asterixdb
COPY assets/entrypoint.sh /opt/entrypoint.sh

EXPOSE 19002 19006

ENTRYPOINT /opt/entrypoint.sh
