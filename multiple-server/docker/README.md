[참고문헌](https://medium.com/@erkndmrl/kafka-cluster-with-docker-compose-5864d50f677e)

## 환경 변수 보니까 INTERNAL/DOCKER/EXTERNAL이 있던데 각각 뭘 의미하는거죠?
```
// kafka.yml - environment
KAFKA_INTER_BROKER_LISTENER_NAME: INTERNAL
KAFKA_ADVERTISED_LISTENERS: INTERNAL://kfk1:19092,DOCKER://host.docker.internal:29092,EXTERNAL://${DOCKER_HOST_IP:-127.0.0.1}:9092
```

- INTERNAL: 내부에서 사용하는 Listener 주소. `KAFKA_INTER_BROKER_LISTENER_NAME` 환경변수를 통해 다른 이름으로 변경할 수 있다.
- DOCKER: docker와 통신하기 위한 네트워크 주소. 즉 EXTERNAL과 같은 동작
- EXTERNAL: 말 그대로 외부와 통신하는 네트워크 주소

여기서 docker와 external은 합칠 수 있습니다! 안쓸수도 있고요.
INTERNAL의 포트는 다른 포트와 겹치지 않는 한 아무거나 적어도 상관없습니다.

## zookeeper가 동작하는데 시간이 조금 걸릴거같아요..
```
environment:
  # 초기화까지 걸리는 시간 조절
  ZOOKEEPER_INIT_LIMIT: 5     # 팔로워가 리더와 초기 동기화하는 시간
  ZOOKEEPER_TICK_TIME: 2000   # 기본 시간 단위 (밀리초)
  # 
  ZOOKEEPER_SYNC_LIMIT: 5     # 동기화 제한 시간

# 총 초기화 허용 시간 = INIT_LIMIT * TICK_TIME
# 5 * 2000ms = 10000ms = 10초
```


## zookeeker가 저장하는 metadata
```
/
├── brokers
│   ├── ids                  # 활성화된 브로커 목록
│   ├── topics              # 토픽 구성 정보
│   └── seqid               # 브로커 ID 시퀀스
├── config
│   ├── topics              # 토픽별 설정
│   ├── clients             # 클라이언트 설정
│   └── changes             # 설정 변경 알림
├── controller              # 현재 컨트롤러 정보
├── controller_epoch        # 컨트롤러 세대 번호
└── admin                   # 관리자 관련 정보
```

## 해당 데이터를 local에 저장하고싶어
volumns를 지정합니다.
```
zookeeper:
  volumes:
    - ./data/zk[id]/data:/var/lib/zookeeper/data        # 데이터 디렉토리
    - ./data/zk[id]/log:/var/lib/zookeeper/log          # 로그 디렉토리

kafka:
  volumes:
    - ./data/kafka[id]/data:/var/lib/kafka/data              # 카프카 데이터 디렉토리
```

```
project/
├── data/
│   ├── zk1/
│   │   ├── data/         # ZK 데이터
│   │   │   ├── myid      # 서버 ID
│   │   │   └── version-2/   # 실제 데이터
│   │   └── log/          # ZK 트랜잭션 로그
│   ├── zk2/
│   │   ├── data/
│   │   └── log/
│   ├── zk3/
│   │   ├── data/
│   │   └── log/
│   ├── kafka1/data/
│   ├── kafka2/data/
│   └── kafka3/data/
```

## host.docker.internal의 의미

| 컨테이너에서 호스트로의 단방향 통신만 보장

broker간 양방향으로 통신해야한다. 일단 broker1 → broker2로 가는 경로를 알아보자.
```
Broker1 → host.docker.internal → Host → Broker2
```

이제 broker1 → broker2 → broker1 hop을 알아보자.
```
Broker1 → host.docker.internal → Host → Broker2 → host.docker.internal → Host → Broker1
```

여기서 zookeeper까지 추가된다면?
```
Broker1 → host.docker.internal → Host → Zookeeper → host.docker.internal → Host → Broker2 → host.docker.internal → Host → Broker1
```

너무 복잡해진다...
하나의 네트워크로 묶으면 되지 않을까? → VPN!

-p 옵션을 통해 서로 다른 프로젝트로 생성했다. 따라서 서로 다른 서버에 있다 가정해도 무방하다.
즉 현재 프로젝트 상황은... 아래와 같이 분리된 서버로 동작한다. 
```
[Server 1]
└── zookeeper1:2181
[Server 2]
└── zookeeper2:2182
[Server 3]
└── zookeeper3:2183
[Server 4]
└── kafka1:9092
[Server 5]
└── kafka2:9093
[Server 6]
└── kafka3:9094
```

이제 이걸 하나의 network로 묶으면...
```
[VPN Network: kafka-network]
├── [Server 1]
│   └── zookeeper1:2181
├── [Server 2]
│   └── zookeeper2:2182
├── [Server 3]
│   └── zookeeper3:2183
├── [Server 4]
│   └── kafka1:9092
├── [Server 5]
│   └── kafka2:9093
└── [Server 6]
    └── kafka3:9094
```

이제 network hop은 아래와 같아진다!
```
Kafka Broker 1 ─┐
Kafka Broker 2 ─┼── [kafka-network] ─── Zookeeper Ensemble
Kafka Broker 3 ─┘     (VPN)         └── (zk1, zk2, zk3)
```