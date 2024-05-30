#!/bin/bash

# "U-54. 사용자 쉘에 대한 환경설정 파일에서 session timeout 설정 여부 점검"

# /etc/profile 파일이 존재하는지 확인
if [ ! -f /etc/profile ]; then
    result=$(ls /etc/profile 2>/dev/null)
    echo "Y"
    echo "/etc/profile 파일을 찾을 수 없습니다"
    echo "$result"
    # exit 1 제거
else
    # /etc/profile 파일에서 TMOUT 변수의 설정값을 확인
    tmout_line=$(grep "^TMOUT" /etc/profile)

    # TMOUT 변수가 설정되어 있지 않은 경우
    if [ -z "$tmout_line" ]; then
        echo "N"
        echo "Session Timeout을 확인할 수 없습니다"
        echo "$tmout_line"
        # exit 1 제거
    else
        # TMOUT 변수의 값을 추출하여 비교
        tmout_value=$(echo "$tmout_line" | awk -F'=' '{print $2}')

        # TMOUT 변수가 600 이하로 설정된 경우
        if [ "$tmout_value" -le 600 ]; then
            echo "Y"
            echo "Session Timeout이 600초 이하로 설정되어 있습니다."
            echo "$tmout_line"
        else
            echo "N"
            echo "Session Timeout이 600초 이하로 설정되어 있지 않습니다."
            echo "$tmout_line"
        fi
    fi
fi
