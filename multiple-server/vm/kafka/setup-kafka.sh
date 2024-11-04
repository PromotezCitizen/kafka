#!/bin/bash

MAIN_VERSION=2.13
VERSION=3.8.1

USER=$(whoami)
BROKER_ID=$1

if [ -z "$BROKER_ID" ]; then
	echo "(1): BROKER_ID is required"
	exit 1
fi

cd /home/$USER
wget https://downloads.apache.org/kafka/$VERSION/kafka_$MAIN_VERSION-$VERSION.tgz && tar xvf kafka_$MAIN_VERSION-$VERSION.tgz
rm kafka_*.tgz

ln -s kafka_$MAIN_VERSION-$VERSION kafka
ln -s kafka/config/server.properties kafka.properties

mkdir -p data

{
	echo "192.168.0.18 zk1"
	echo "192.168.0.19 zk2"
	echo "192.168.0.21 zk3"
} | sudo tee -a /etc/hosts > /dev/null

cat <<EOL > start.sh
/home/$(whoami)/kafka/bin/kafka-server-start.sh -daemon kafka.properties
EOL

cat <<EOL > end.sh
/home/$(whoami)/kafka/bin/kafka-server-stop.sh
EOL

cat <<EOL > consumer.sh
/home/$(whoami)/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test-topic
EOL

cat <<EOL > producer.sh
/home/$(whoami)/kafka/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic test-topic
EOL

cat <<EOL > create-topic.sh
/home/$(whoami)/kafka/bin/kafka-topics.sh --create --topic test-topic --bootstrap-server localhost:9092 --partitions 3 --replication-factor 3
EOL

chmod +x *.sh