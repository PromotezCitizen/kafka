param (
  [int]$zookeeperContainerCount = 3,
  [int]$kafkaContainerCount = 3,
  [string] $zookeeperContainerNamePattern = "zk",
  [string] $kafkaContainerNamePattern = "kfk"
)

# zookeeper 실행
for ($i = 1; $i -le $zookeeperContainerCount; $i++) {
  $env:ZOOKEEPER_SERVER_ID = $i
  Start-Process -NoNewWindow -PassThru -File "docker" -ArgumentList "compose -f zookeeper/zookeeper$i.yml -p $zookeeperContainerNamePattern$i up -d"
}

do {
  $runningZookeeperContainers = docker ps --filter "name=$zookeeperContainerNamePattern" --format "{{.Names}}"
  if (-not $runningZookeeperContainers) {
    Start-Sleep -Seconds 3
  }
} while (-not $runningZookeeperContainers)

# kafka 실행
for ($i = 1; $i -le $zookeeperContainerCount; $i++) {
  $env:KAFKA_BROKER_ID = $i
  Start-Process -NoNewWindow -PassThru -File "docker" -ArgumentList "compose -f kafka/kafka$i.yml -p $kafkaContainerNamePattern$i up -d"
}

do {
  $runningZookeeperContainers = docker ps --filter "name=$kafkaContainerNamePattern" --format "{{.Names}}"
  if (-not $runningZookeeperContainers) {
    Start-Sleep -Seconds 3
  }
} while (-not $runningZookeeperContainers)

# topic: test-topic 생성
Start-Sleep -Seconds 10
# docker compose -f docker-compose.kafka1.yml -p kfk1 exec kfk1 kafka-topics --create --topic test-topic --bootstrap-server localhost:19092 --replication-factor 1 --partitions 3

# rest 전송 및 zookeeper 상태 확인 가능한 controller들 실행
Start-Process -NoNewWindow -PassThru -File "docker" -ArgumentList "compose -f controller.yml -p kfk-controller up -d"