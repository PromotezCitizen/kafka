param (
  [int]$zookeeperContainerCount = 3,
  [int]$kafkaContainerCount = 3,
  [string] $zookeeperContainerNamePattern = "zk",
  [string] $kafkaContainerNamePattern = "kfk"
)

# 종료 스크립트 실행
& "stop.ps1" `
  -zookeeperContainerCount $zookeeperContainerCount `
  -kafkaContainerCount $kafkaContainerCount `
  -zookeeperContainerNamePattern $zookeeperContainerNamePattern `
  -kafkaContainerNamePattern $kafkaContainerNamePattern

Start-Sleep -Seconds 5

# 시작 스크립트 실행
& "start.ps1" `
  -zookeeperContainerCount $zookeeperContainerCount `
  -kafkaContainerCount $kafkaContainerCount `
  -zookeeperContainerNamePattern $zookeeperContainerNamePattern `
  -kafkaContainerNamePattern $kafkaContainerNamePattern