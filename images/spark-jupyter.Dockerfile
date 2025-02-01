ARG SPARK_BASE
FROM ${SPARK_BASE}

USER root

RUN pip install jupyter 

WORKDIR /home/spark

COPY --chown=spark:root --chmod=777 entrypoint.sh /home/spark/entrypoint.sh

USER spark

ENTRYPOINT ["bash", "-c", "./entrypoint.sh"]