#!/bin/bash


curl -O https://packages.confluent.io/archive/7.7/confluent-community-7.7.1.tar.gz && tar xzf confluent-*.tar.gz
ln -s confluent-7.7.1 confluent

mkdir -p confluent/etc/kafka
echo <<EOL > confluent/etc/kafka/kafka-rest.properties
bootstrap.servers=192.168.0.22:9092,192.168.0.24:9092,182.168.0.20:9092
listeners=http://0.0.0.0:8082
EOL
ln -s confluent/etc/kafka/kafka-rest.properties rest.properties # 설정 파일을 home으로 링크

echo <<EOL > start.sh
./confluent/bin/kafka-rest-start rest.properties
EOL

ecoh <<EOL > stop.sh
./confluent/bin/kafka-rest-stop
EOL