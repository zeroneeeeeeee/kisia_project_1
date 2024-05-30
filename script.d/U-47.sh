#!/bin/bash

# /etc/login.defs 파일을 열어서 PASS_MAX_DAYS 값을 확인하여 양호 또는 취약 여부를 판단하는 스크립트
# "U-47. 시스템 정책에 따라 비밀번호 최대 사용기간 설정 적용 여부"

# /etc/login.defs 파일 경로
login_defs_file="/etc/login.defs"

# /etc/login.defs 파일 존재 여부 확인
if [ ! -f $login_defs_file ]; then
    echo "Y"
    echo "/etc/login.defs를 찾을 수 없습니다."
    result=$(ls $login_defs_file 2>/dev/null)
    echo "$result"
    # exit 1
fi

# PASS_MAX_DAYS 설정의 전체 라인 가져오기
pass_max_days_line=$(grep "^PASS_MAX_DAYS" $login_defs_file)

# PASS_MAX_DAYS 값 추출
pass_max_days=$(echo "$pass_max_days_line" | awk '{print $2}')

# PASS_MAX_DAYS 설정 여부 확인
if [[ -z $pass_max_days_line ]]; then
    echo "N/A"
    echo "패스워드 최대 유효 기간을 확인할 수 없습니다."
else
    # PASS_MAX_DAYS가 90 이하인지 확인하여 결과 출력
    if [[ $pass_max_days -le 90 ]]; then
        echo "Y"
        echo "패스워드 최대 유효 기간이 90일 이하로 설정되어 있습니다."
        echo "설정된 줄: $pass_max_days_line"
    else
        echo "N"
        echo "패스워드 최대 유효 기간이 90일 초과로 설정되어 있습니다."
        echo "설정된 줄: $pass_max_days_line"
    fi
fi

