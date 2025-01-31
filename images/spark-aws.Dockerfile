FROM docker.io/library/spark:3.5.4-java17-python3 

# Spark and Iceberg versions
ARG SPARK_VERSION=3.5.4
ARG SPARK_MAJOR_VERSION=3.5
ARG HADOOP_VERSION=3.3.4
ARG AWS_SDK_VERSION=1.12.780
ARG BOUNCY_CASTLE_VERSION=1.80

USER root

# Download Hadoop AWS bundle
RUN curl -s https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar \
  -Lo /opt/spark/jars/hadoop-aws.jar

# Download AWS SDK bundle
RUN curl -s https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_SDK_VERSION}/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar \
  -Lo /opt/spark/jars/aws-sdk-bundle.jar


RUN curl https://repo1.maven.org/maven2/org/bouncycastle/bcprov-jdk18on/${BOUNCY_CASTLE_VERSION}/bcprov-jdk18on-${BOUNCY_CASTLE_VERSION}.jar \
  -Lo /opt/spark/jars/bcprov-jdk18on.jar

RUN curl https://repo1.maven.org/maven2/org/bouncycastle/bcpkix-jdk18on/${BOUNCY_CASTLE_VERSION}/bcpkix-jdk18on-${BOUNCY_CASTLE_VERSION}.jar \
  -Lo /opt/spark/jars/bcpkix-jdk18on.jar

USER spark