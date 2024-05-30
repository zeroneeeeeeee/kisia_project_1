#!/bin/bash

# Apache 설정 파일 경로
apache_conf="/etc/apache2/apache2.conf"

# 설정 파일 존재 여부 확인
if [ ! -f "$apache_conf" ]; then
    echo "Y"
    echo "apache2.conf 파일을 찾을 수 없습니다."
    result=$(ls -ld /etc/apache2 2>/dev/null)
    echo "$result"
else
    # 파일에서 주석이 아닌 디렉토리 설정의 모든 내용 찾기
    directories=$(awk '/<Directory/,/<\/Directory>/' $apache_conf | grep -vE '^\s*#')

    # LimitRequestBody 설정 값을 저장
    limit_request_body_value=""
    while read -r line; do
        if [[ $line == *"LimitRequestBody"* ]]; then
            limit_request_body_value=$(echo $line | cut -d' ' -f2)
            break
        fi
    done < "$apache_conf"

    # 설정이 존재하지 않거나 잘못된 경우의 결과 출력
    if [ -z "$limit_request_body_value" ]; then
        echo "N/A"
        echo "수동 점검이 필요합니다."
        echo "$directories"
    else
        echo "N/A"
        echo "수동 점검이 필요합니다."
        echo "LimitRequestBody가 설정된 값: $limit_request_body_value"
        echo "$directories"
    fi
fi

# 스크립트가 자연스럽게 종료되도록 설정
# exit 명령은 제거함
