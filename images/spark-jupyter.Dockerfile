FROM 192.168.1.3:3000/binayakd/spark-aws:3.5.4

USER root

RUN mkdir -p /home/spark && chown spark:spark /home/spark

RUN pip install jupyter 

USER spark

WORKDIR /home/spark

COPY --chown=spark:spark --chmod=777 entrypoint.sh /home/spark/entrypoint.sh

ENV PYTHONPATH=${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.9.7-src.zip:${PYTHONPATH}

CMD ["bash", "-c", "./entrypoint.sh"]