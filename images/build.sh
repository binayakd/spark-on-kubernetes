#/bin/bash

set -ex

# Change here to point to the registry, path and tags you want
export SPARK_AWS_IMAGE=192.168.1.3:3000/binayakd/spark-aws:3.5.4
export SPARK_JUPYTER_IMAGE=192.168.1.3:3000/binayakd/spark-aws-jupyter:3.5.4


echo "Building ${SPARK_AWS_IMAGE}"
podman build -t ${SPARK_AWS_IMAGE} -f spark-aws.Dockerfile

echo "Pushing ${SPARK_AWS_IMAGE}"
podman push ${SPARK_AWS_IMAGE}

echo "Building ${SPARK_JUPYTER_IMAGE}"
podman build -t ${SPARK_JUPYTER_IMAGE} --build-arg SPARK_BASE=${SPARK_AWS_IMAGE} -f spark-jupyter.Dockerfile

echo "Pushing ${SPARK_JUPYTER_IMAGE}"
podman push ${SPARK_JUPYTER_IMAGE}