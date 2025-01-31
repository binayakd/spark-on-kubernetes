# Spark on Kubernetes

## Prerequisites

Infra setup:
- K3s kubernetes
- longhorn for storage
- metallb for networking


## Setup Minio

### Kube resources deployment
1. pvc
2. deployment
3. service

### setup bucket

Connect to minio instance
```bash
mc alias set sparkminio http://192.168.1.5:9000 sparkminio sparkminio
```
``` bash
$ mc admin info sparkminio
●  192.168.1.5:9000
   Uptime: 18 minutes 
   Version: 2025-01-20T14:49:07Z
   Network: 1/1 OK 
   Drives: 1/1 OK 
   Pool: 1

┌──────┬──────────────────────┬─────────────────────┬──────────────┐
│ Pool │ Drives Usage         │ Erasure stripe size │ Erasure sets │
│ 1st  │ 0.0% (total: 49 GiB) │ 1                   │ 1            │
└──────┴──────────────────────┴─────────────────────┴──────────────┘

1 drive online, 0 drives offline, EC:0
```
Create 2 buckets:

spark-logs:
```bash
mc mb sparkminio/spark-logs
```

data:
```bash
mc mb sparkminio/data
```
## Create Container Image

```bash
podman build -t 192.168.1.3:3000/binayakd/spark-aws:3.5.4 .
podman push 192.168.1.3:3000/binayakd/spark-aws:3.5.4
```

```bash
podman build -t spark-aws-jupyter:3.5.4 .
```

```bash
podman run 