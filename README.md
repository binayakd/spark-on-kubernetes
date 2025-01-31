# Spark on Kubernetes

## Prerequisites

Local build/deployment env:
- Podman
- Kubectl/Kustomize
- Minio client

Infra setup:
- K3s kubernetes
- longhorn for storage
- metallb for networking

## Build Spark images

Update registry, path and tags to use for the images in `images/build.sh`, and run the script to use podman to build following images:

1. spark-aws: Spark image with aws dependence that would be used for the spark drivers, executors and spark history server
2. spark-jupyter: Spark base image with Jupyter Lab installed, to act as out workspace to work with Spark in K8s, and trigger Spark jobs, from withing the cluster

## Create and deploy k8s resources

Update the images names and tags in `kube/kustomization.yaml`, and run `kustomize build ./kube -o output` to generate the k8s manifests. The resources that will be produced will be:

1. Namespace
2. RBAC configs for Spark submit (from jupyter lab) and spark driver
3. Minio 
   - pvc
   - deployment
   - service
4. Spark History Server
   - spark-conf configmap
   - deployment
   - service
5. Spark Jupyter Lab
   - pvc
   - deployment
   - service

You can either deploy all of them at once (if you are brave) or one by one (recommended).

### Setup Minio Bucket

Connect to minio instance using minio client
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
Create the bucket `spark-on-kube`:

```bash
mc mb sparkminio/spark-on-kube
```

Upload an empty file in the minio path where we want to push the spark event logs to:

```bash
touch tmp.txt
mc put ./tmp.txt sparkminio/spark-on-kube/event-logs/tmp.txt
```
This step in needed because of a [bug (or feature?)](https://issues.apache.org/jira/browse/HADOOP-15140?page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel&focusedCommentId=16344201) where trying to set the root of a S3 (or minio) bucket for the location of the event logs results in the driver failing with the error `java.lang.IllegalArgumentException: path must be absolute`, and if the path does not already exists, Spark History Server will fail with the error `Path Not Found`. 

So to get around it we set the location to be a subpath under the root of the bucket, and push an empty file to that path, to make sure Spark History Server see the path existing. 

## Testing A Spark Job

Once all the k8s resources are deployed, access the Jupyter Lab instance, and upload the script: `workspace/spark-pi.sh` to run the pyspark Pi example. 

Access the Spark History Server instance to see the Job info after the job completes. 