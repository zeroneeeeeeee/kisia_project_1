#!/bin/bash

# /etc/apache2 디렉토리의 존재 여부를 확인
if [ ! -d "/etc/apache2" ]; then
    echo "Y"
    echo "/etc/apache2를 찾을 수 없습니다"
    result=$(ls -ld /etc/apache2  2>/dev/null)  # 디렉토리가 없을 경우의 오류 메시지를 포함 -> 2>&1 : 표준 오류(디렉토리가 없을 때 발생하는 오류 메세지)를 표준으로 리다이렉트하여 변수에 저장
    echo "$result"

else
    # /etc/apache2 디렉토리가 존재하는 경우, 하위 디렉토리 확인
    if [ -d "/etc/apache2/htdocs/manual" ] || [ -d "/etc/apache2/manual" ]; then # if -d : 디렉토리 중 하나라도 존재하는지 확인
        echo "N"
        echo "기본으로 생성되는 불필요한 파일 및 디렉토리가 제거되지 않았습니다"

    else
        echo "Y"
        echo "기본으로 생성되는 불필요한 파일 및 디렉토리가 제거되어 있습니다"
    fi

    # 결과 확인을 위해 /etc/apache2 디렉토리 상태 출력
    result=$(ls -l /etc/apache2)
    echo "$result"
fi

