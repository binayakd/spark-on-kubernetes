#/bin/bash

podman build -t 192.168.1.3:3000/binayakd/spark-aws:3.5.4 .
podman push 192.168.1.3:3000/binayakd/spark-aws:3.5.4