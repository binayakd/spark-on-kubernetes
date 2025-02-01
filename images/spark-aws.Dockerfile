# staging to download and collect all the required dependencies 
FROM registry.access.redhat.com/ubi9/ubi as stage

# Versions
ARG SPARK_VERSION=3.5.4
ARG SPARK_MAJOR_VERSION=3.5
ARG HADOOP_VERSION=3.3.4
ARG AWS_SDK_VERSION=1.12.780
ARG BOUNCY_CASTLE_VERSION=1.80

WORKDIR /opt

# Download and untar spark
RUN mkdir -p /opt/spark/ \
 && curl -fsSL https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz -o spark-${SPARK_VERSION}-bin-hadoop3.tgz \
 && tar xvzf spark-${SPARK_VERSION}-bin-hadoop3.tgz --directory /opt/spark/ --strip-components 1 \
 && rm -rf spark-${SPARK_VERSION}-bin-hadoop3.tgz

# Download AWS bundles to connect with S3
RUN curl -fsSL https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar \
  -o /opt/spark/jars/hadoop-aws.jar \
  && curl -fsSL https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_SDK_VERSION}/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar \
  -o /opt/spark/jars/aws-sdk-bundle.jar

# Download bouncy castle dependencies for authentication with k8s API
RUN curl -fsSL https://repo1.maven.org/maven2/org/bouncycastle/bcprov-jdk18on/${BOUNCY_CASTLE_VERSION}/bcprov-jdk18on-${BOUNCY_CASTLE_VERSION}.jar \
  -o /opt/spark/jars/bcprov-jdk18on.jar \
  && curl -fsSL https://repo1.maven.org/maven2/org/bouncycastle/bcpkix-jdk18on/${BOUNCY_CASTLE_VERSION}/bcpkix-jdk18on-${BOUNCY_CASTLE_VERSION}.jar \
  -o /opt/spark/jars/bcpkix-jdk18on.jar


# Main image 
FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

# user IDs to run image as
ARG RUN_AS_USER=1000

# update and install java and python dependencies
RUN microdnf update -y \
  && microdnf --nodocs install shadow-utils java-21-openjdk-headless python3.12 python3.12-setuptools python3.12-pip tar gzip procps -y \
  && microdnf clean all -y \
  && rm -f /usr/bin/python \
  && rm -f /usr/bin/python3 \
  && ln -s /usr/bin/python3.12 /usr/bin/python \
  && ln -s /usr/bin/python3.12 /usr/bin/python3 \
  && ln -s /usr/bin/pip3.12 /usr/bin/pip \
  && ln -s /usr/bin/pip3.12 /usr/bin/pip3

# Install tini
ARG TINI_VERSION=v0.19.0
ARG TINI_ARCH=amd64
RUN curl -fsSL "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-${TINI_ARCH}" -o /usr/bin/tini \
  && chmod +x /usr/bin/tini

# set up non root user
RUN useradd -u ${RUN_AS_USER} -g root spark

# setup opt dir for spark user
RUN mkdir -p /opt/spark/ && chown -R spark:root /opt

# Copy all the spark files
COPY --from=stage --chown=spark:root /opt/spark/jars /opt/spark/jars
COPY --from=stage --chown=spark:root /opt/spark/bin /opt/spark/bin
COPY --from=stage --chown=spark:root /opt/spark/sbin /opt/spark/sbin
COPY --from=stage --chown=spark:root /opt/spark/kubernetes/dockerfiles/spark/entrypoint.sh /opt/
COPY --from=stage --chown=spark:root /opt/spark/kubernetes/dockerfiles/spark/decom.sh /opt/
COPY --from=stage --chown=spark:root /opt/spark/examples /opt/spark/examples

# Pyspark files
COPY --from=stage --chown=spark:root /opt/spark/python/pyspark /opt/spark/python/pyspark
COPY --from=stage --chown=spark:root /opt/spark/python/lib /opt/spark/python/lib

# Setup env variables
ENV JAVA_HOME=/usr/lib/jvm/jre-21
ENV SPARK_HOME=/opt/spark
ENV PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH

# setting up work dir and permissions
WORKDIR /opt/spark/work-dir
RUN chmod g+w /opt/spark/work-dir
RUN chmod a+x /opt/decom.sh

ENTRYPOINT [ "/opt/entrypoint.sh" ]

# switch to spark user
USER spark

