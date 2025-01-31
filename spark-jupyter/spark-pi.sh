#/bin/bash

$SPARK_HOME/bin/spark-submit \
    --master k8s://https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT_HTTPS} \
    --deploy-mode cluster \
    --name spark-pi \
    --class org.apache.spark.examples.SparkPi \
    --conf spark.executor.instances=3 \
    --conf spark.kubernetes.container.image=192.168.1.3:3000/binayakd/spark-aws:3.5.4 \
    --conf spark.kubernetes.namespace=spark \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
    --conf spark.eventLog.enabled=true \
    --conf spark.eventLog.dir='s3a://spark-on-kube/event-logs/' \
    --conf spark.hadoop.fs.s3a.access.key=sparkminio \
    --conf spark.hadoop.fs.s3a.secret.key=sparkminio \
    --conf spark.hadoop.fs.s3a.endpoint='http://192.168.1.5:9000' \
    --conf spark.hadoop.fs.s3a.path.style.access=true \
    --conf spark.hadoop.fs.s3a.connection.ssl.enabled=false\
    --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
    local:///opt/spark/examples/src/main/python/pi.py \
    1000