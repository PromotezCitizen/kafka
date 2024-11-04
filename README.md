# Kafka test
자바와 gradle을 기반으로 한 카프카 테스트용 자바 프로그램

자바 17 이상이면 문제 없이 실행됩니다.

# Single Server
docker-compose 하나에 모든 카프카와 zookeeper를 때려박은 것입니다.

실제로 이렇게 하면 안됩니다. 다만 동작을 확인하기 위해서는 문제 없음!

# Multiple Server
분산 환경에서는 어떻게 해야할지 직접 겪어봤습니다.   
카프카 노드 3개, 주키퍼 노드 3개를 이용하였습니다.

## Docker
Docker를 이용한 분산 서버를 흉내내었습니다. network로 묶여있더라도 서버 자체는 분산인가?

docker network는 대충 말하면 dns를 지원하는 vpn이다!

start.ps1, stop.ps1으로 윈도우 파워쉘 환경에서 쉽게 동작을 볼 수 있도록 하였습니다.

## VM
실제로 분산 서버를 구현하였습니다.   
Host Network에 브릿지라 네트워크는 묶여있지만, 서로 다른 vm에서 동작하는거라 분산된 서버로 볼 수 있습니다.