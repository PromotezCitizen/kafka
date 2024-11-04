#!/bin/bash

# 변수 설정
USER=$(whoami)
ZOOKEEPER_ID=$1
VERSION=3.9.3

if [ -z "$ZOOKEEPER_ID" ]; then
	echo "(1): ZOOKEEPER_ID is required"
	exit 1
fi

cd /home/$USER
wget https://dlcdn.apache.org/zookeeper/zookeeper-3.9.3/apache-zookeeper-$VERSION-bin.tar.gz && tar xvf apache-zookeeper-*-bin.tar.gz
rm apache-zookeeper-*-bin.tar.gz

ln -s apache-zookeeper-$VERSION-bin zookeeper

cd ~/zookeeper/conf || exit

cat <<EOL > zoo.cfg
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/home/$USER/zookeeper/data
clientPort=2181
server.1=zk1:2888:3888
server.2=zk2:2888:3888
server.3=zk3:2888:3888
EOL

mkdir -p ~/zookeeper/data
echo $ZOOKEEPER_ID > ~/zookeeper/data/myid

{
    if [ "$ZOOKEEPER_ID" -eq 1 ]; then
        echo "0.0.0.0 zk1"
    else
        echo "192.168.0.18 zk1"
    fi

    if [ "$ZOOKEEPER_ID" -eq 2 ]; then
        echo "0.0.0.0 zk2"
    else
        echo "192.168.0.19 zk2"
    fi

    if [ "$ZOOKEEPER_ID" -eq 3 ]; then
        echo "0.0.0.0 zk3"
    else
        echo "192.168.0.21 zk3"
    fi
} | sudo tee -a /etc/hosts > /dev/null

cd ~

cat <<EOL > start.sh
/home/$(whoami)/zookeeper/bin/zkServer.sh start
EOL

cat <<EOL > stop.sh
/home/$(whoami)/zookeeper/bin/zkServer.sh stop
EOL

cat <<EOL > status.sh
/home/$(whoami)/zookeeper/bin/zkServer.sh status
EOL

chmod +x *.sh

echo "ZooKeeper 설정 완료!"