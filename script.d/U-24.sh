#!/bin/bash

#  ps -ef 명령어로 먼저 모든 프로세스 상태를 확인
# grep명령어의 -iE 옵션을 주어 대소문자를 가리지 않고 정규표현식으로 패턴을 찾는다.
# grep 옵션중 -v는 일치하지 않는 행만 출력한다.

# 즉  -ivE 옵션은 주어진 패턴과 대소문자를 가림없이 일치하지 않는 행을 선택하여 출력하도록 지정합니다. 이 경우, grep 명령어가 'grep', 'kblockd', 'rstatd'와 같>은 예외 프로세스를 무시>하고 NFS와 관련된 프로세스만 필터링하도록 되어있다.

if [ $(ps -ef | grep -iE 'nfs|rpc.statd|statd|rpc.lockd|lockd' | grep -ivE 'grep|kblockd|rstatd|' | wc -l) -gt 0 ]; then
    echo "N"
    echo "불필요한 NFS 서비스 관련 데몬이 활성화 되어 있습니다."
else
    echo "Y"
    echo "불필요한 NFS 서비스 관련 데몬이 비활성화 되어 있습니다."
fi
# wc -l로 필터링된 결과의 라인수를 세어준다.
P=$(ps -ef | grep -E "nfs\|rpc.statd\|statd\|rpc.lockd\|lockd")
echo "$P"