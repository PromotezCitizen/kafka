param (
  [int]$zookeeperContainerCount = 3,
  [int]$kafkaContainerCount = 3,
  [string] $zookeeperContainerNamePattern = "zk",
  [string] $kafkaContainerNamePattern = "kfk"
)

# kafka 종료
for ($i = 1; $i -le $zookeeperContainerCount; $i++) {
  Start-Process -NoNewWindow -PassThru -File "docker" -ArgumentList "compose -f kafka/kafka$i.yml -p $kafkaContainerNamePattern$i down"
}

Start-Process -NoNewWindow -PassThru -File "docker" -ArgumentList "compose -f controller.yml -p kfk-controller down"

do {
  $runningKafkaContainers = docker ps --filter "name=$kafkaContainerNamePattern" --format "{{.Names}}"
  if ($runningKafkaContainers) {
    Start-Sleep -Seconds 3
  }
} while ($runningKafkaContainers)

# zookeeper 종료
for ($i = 1; $i -le $zookeeperContainerCount; $i++) {
  Start-Process -NoNewWindow -PassThru -File "docker" -ArgumentList "compose -f zookeeper/zookeeper$i.yml -p $zookeeperContainerNamePattern$i down"
}