#!/bin/bash

# automountd 서비스 데몬을 확인하는 명령어를 실행하고 결과를 변수에 저장

#  ps -ef 명령어로 먼저 모든 프로세스 상태를 확인
# grep -v 옵션을 주어 ps -ef 명령어의 출력에서 자기 자신을 제외한 결과를 필터링한다.
#  grep -c 옵션을 주어 'automountd' 또는 'autofs'와 일치하는 행의 개수를 센다.

service_check=$(ps -ef | grep -v grep | grep -c 'automountd\|autofs')


# service_check에 결과를 저장하고 service_check가 0이면 'automountd' 서비스가 비활성화되어 있다고 판단하여 "Y"를 출력합니다. 그렇지 않으면 "N"을 출력
if [ $service_check -eq 0 ]; then
    echo "Y"
    echo "Automountd 서비스가 비활성화 되어 있습니다."
else
    echo "N"
    echo "Automountd 서비스가 활성화 되어 있습니다."
fi
SY=$(systemctl status automountd | grep "$service_check")
echo "$SY"