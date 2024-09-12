#!/bin/bash

mkdir -p notebooks/jars
cd notebooks/jars

wget https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/2.17.178/bundle-2.17.178.jar

wget https://repo1.maven.org/maven2/software/amazon/awssdk/url-connection-client/2.17.178/url-connection-client-2.17.178.jar

wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/3.3.6/hadoop-common-3.3.6.jar

wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.6/hadoop-aws-3.3.6.jar

wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-client/3.3.6/hadoop-client-3.3.6.jar

wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.765/aws-java-sdk-bundle-1.12.765.jar

wget https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.6.1/iceberg-spark-runtime-3.5_2.12-1.5.2.jar

wget https://repo.maven.apache.org/maven2/org/projectnessie/nessie-integrations/nessie-spark-extensions-3.5_2.12/0.95.0/nessie-spark-extensions-3.5_2.12-0.94.1.jar

