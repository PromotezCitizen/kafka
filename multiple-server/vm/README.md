## VM 할당
| Virtual Machine | CPU Core | RAM | 저장공간 | 설명 |
| --- | --- | --- | --- | --- |
| Zookeeper | 1 | 3GB | 25GB |  |
| Kafka | 1~2 | 4GB | 40GB | CPU는 2코어를 최소로 잡지만 테스트 용도로 1코어만 주었습니다. |
| **Ubuntu Server | 1 | 512MB | 2.5GB | Zookeeper와 Kafka에 모두 적용되는 기본 OS입니다. |

## 스크립트 수정
자신의 vm에 맞게 ip table을 수정합니다.  
현재 스크립트에 작성된 내용은 제 pc의 vm 기준으로 작성되어있습니다.

## 스크립트 실행
모든 스크립트는 `setup-***.sh $1`으로 입력받습니다.   
`$1`에는 kafka_id 또는 zookeeper_id를 넣어줍니다.