#!/bin/bash

# "U-53. 로그인이 불필요한 계정에 쉘 부여 여부 점검"

# /etc/passwd 파일 존재 여부 확인
if [ ! -f /etc/passwd ]; then
    echo "Y"
    echo "/etc/passwd 파일을 찾을 수 없습니다"
    skip_rest_of_script=true
else
    skip_rest_of_script=false
fi

# 스크립트의 나머지 부분은 skip_rest_of_script 변수 상태에 따라 실행
if [ "$skip_rest_of_script" = false ]; then
    # Define the threshold for system accounts
    MIN_UID=100
    MAX_UID=60000

    # 계정 정보를 저장할 변수 초기화
    assigned_accounts=""
    unassigned_accounts=""

    # /etc/passwd 파일의 각 줄을 순환하며 계정 정보를 읽음
    while IFS=: read -r username _ uid _ _ _ shell; do
        # 사용자가 시스템 계정인지 확인
        if (( uid <= MIN_UID || uid >= MAX_UID )); then
            # 계정 쉘이 /bin/false인지 /sbin/nologin인지 확인
            if [[ $shell == "/bin/false" || $shell == "/sbin/nologin" || $shell == "/usr/sbin/nologin" ]]; then
                assigned_accounts+="$username:$_:$uid:$_:$_:$shell\n"
            elif [[ $shell != "/bin/false" && $shell != "/sbin/nologin" && $shell != "/usr/sbin/nologin" ]]; then
                unassigned_accounts+="$username:$_:$uid:$_:$_:$shell\n"
            fi
        fi  
    done < /etc/passwd

    # 출력
    if [[ -n $assigned_accounts ]]; then
        echo "Y"
        echo "로그인이 필요하지 않은 계정에 쉘이 부여되어 있는 경우"
        echo -e "$assigned_accounts"
    elif [[ -n $unassigned_accounts ]]; then
        echo "N"
        echo "로그인이 필요하지 않은 계정에 쉘이 부여되지 않은 경우"
        echo -e "$unassigned_accounts"
    fi
fi
