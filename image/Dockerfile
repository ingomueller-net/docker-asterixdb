FROM maven:3.8.1-adoptopenjdk-15 AS builder
MAINTAINER Ingo Müller <ingo.mueller@inf.ethz.ch>

ARG ASTERIXDB_REV=03fd6d0f
ARG MAVEN_OPTS

ENV HADOOP_HOME /opt/hadoop

# Tools for building
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        unzip \
        wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and unpack AsterixDB
RUN cd /tmp && \
    wget --progress=dot:giga -O asterix-server.tar.gz \
        "https://asterix-gerrit.ics.uci.edu/changes/asterixdb~12763/revisions/3/archive?format=tgz" && \
    tar -xzf asterix-server.tar.gz && \
    mvn clean package -DskipTests && \
    mv asterixdb/asterix-server/target/asterix-server-*-binary-assembly/apache-asterixdb-*-SNAPSHOT/ /opt/asterixdb && \
    rm -rf /root/.m2

# Download and unpack Hadoop
RUN mkdir $HADOOP_HOME && \
    cd $HADOOP_HOME && \
    wget --progress=dot:giga https://archive.apache.org/dist/hadoop/core/hadoop-3.2.2/hadoop-3.2.2.tar.gz -O - | \
         tar -xz --strip-components=1


FROM adoptopenjdk:15-jre-hotspot-focal

ENV HADOOP_HOME /opt/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin

# Runtime depencensies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        # For AsterixDB
        procps \
        # For docker-compose
        wait-for-it \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/asterixdb /opt/asterixdb
COPY --from=builder $HADOOP_HOME $HADOOP_HOME
COPY scripts/asterixdb-entrypoint.sh /opt/asterixdb-entrypoint.sh
COPY hadoop/etc $HADOOP_HOME/etc

RUN hdfs namenode -format && rm -rf /opt/hadoop/logs/*

EXPOSE 19002 19006

CMD /opt/asterixdb-entrypoint.sh
