#!/bin/bash

# named 프로세스가 실행 중인지 확인
ps_output=$(ps -aux | grep '[n]amed')  # 'ps' 명령어를 사용하여 모든 프로세스를 조회하고, 'named'을 포함하는 프로세스를 검색함.
if [ -n "$ps_output" ]; then  # 프로세스 출력이 비어 있지 않으면, 'named' 프로세스가 실행 중인 것으로 판단함.
    # BIND 9 패키지의 버전 정보 가져오기
    dpkg_bind9_version=$(dpkg -s bind9 2>/dev/null | grep -i 'version' | awk '{print $2}')  # 'dpkg' 명령어를 사용하여 BIND 9 패키지의 설치된 버전 정보를 가져옴.

    # 버전이 존재하는지 확인
    if [ -n "$dpkg_bind9_version" ]; then  # 버전 정보가 존재하는 경우,
        # 버전이 9.18로 시작하는지 확인
        if [[ "$dpkg_bind9_version" == 9.18.* ]]; then  # 버전이 '9.18'로 시작하는지 확인함.
            # 버전이 9.18.x 형식인 경우, 패치 버전을 추출하여 확인
            patch_version=$(echo "$dpkg_bind9_version" | awk -F '.' '{print $3}')  # '.'을 구분자로 사용하여 패치 버전을 추출함.
            # 패치 버전이 [7-9]* 또는 1[0-6]*와 일치하지 않으면 최신 버전이 아닙니다.
            if [[ "$patch_version" != [7-9]* && "$patch_version" != 1[0-6]* ]]; then  # 패치 버전이 '7'에서 '9' 또는 '10'에서 '16' 사이의 범위에 속하지 않으면 최신 버전이 아니라고 판단함.
                result="N"  # 결과 변수를 "N"으로 설정함.
                message="DNS 서비스를 사용하지 않거나 주기적으로 패치를 관리하고 있지 않습니다."  # 결과 메시지를 해당 내용으로 변경함.
            else
                result="Y"  # 결과 변수를 "Y"로 설정함.
                message="DNS 서비스를 사용하며 주기적으로 패치를 관리하고 있습니다. 패치 버전: $patch_version"  # 결과 메시지를 해당 내용으로 변경함.
            fi
        else
            # 버전이 9.18로 시작하지 않는 경우 최신 버전이 아닙니다.
            result="N"  # 결과 변수를 "N"으로 설정함.
            message="DNS 서비스를 사용하지 않거나 주기적으로 패치를 관리하고 있지 않습니다."  # 결과 메시지를 해당 내용으로 변경함.
        fi
    else
        # 패키지 정보를 찾을 수 없는 경우
        result="N"  # 결과 변수를 "N"으로 설정함.
        message="DNS 서비스를 사용하지 않거나 주기적으로 패치를 관리하고 있지 않습니다."  # 결과 메시지를 해당 내용으로 변경함.
    fi
else
    # named 프로세스가 실행 중이 아니거나 찾을 수 없는 경우
    result="Y"  # 결과 변수를 "Y"로 설정함.
    message="DNS 서비스가 실행되고 있지 않거나 찾을 수 없습니다."  # "named" 프로세스가 실행되고 있지 않다는 메시지를 결과 메시지로 설정함.
fi

# 결과 출력
echo "$result"
echo "$message"

# named 프로세스 정보 출력
pp=$(ps -ef | grep named)
echo "$pp"
