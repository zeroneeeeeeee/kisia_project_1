#!/bin/bash

# /etc/login.defs 파일을 열어서 PASS_MIN_DAYS 값을 확인하여 양호 또는 취약 여부를 판단하는 스크립트
# "U-48. 시스템 정책에 따라 비밀번호 최소 사용기간 설정 적용 여부"

# /etc/login.defs 파일 경로
login_defs_file="/etc/login.defs"

# /etc/login.defs 파일 존재 여부 확인
if [ ! -f $login_defs_file ]; then
    echo "Y"
    echo "/etc/login.defs를 찾을 수 없습니다."
    result=$(ls $login_defs_file 2>/dev/null) # 2>&1 : 표준 에러를 표준 출력으로 리디렉션
    echo "$result"
    # exit 1
fi

# PASS_MIN_DAYS 설정의 전체 라인 가져오기
pass_min_days_line=$(grep "^PASS_MIN_DAYS" $login_defs_file)

# PASS_MIN_DAYS 값 추출
pass_min_days=$(echo "$pass_min_days_line" | awk '{print $2}')

# PASS_MIN_DAYS 설정 여부 확인
if [[ -z $pass_min_days_line ]]; then
    echo "N/A"
    echo "패스워드 최소 유효 기간을 확인할 수 없습니다."
    echo "$pass_min_days_line"
elif [[ $pass_min_days -ge 1 ]]; then
    echo "Y"
    echo "패스워드 최소 유효 기간이 1일 이상으로 설정되어 있습니다."
    echo "$pass_min_days_line"
else
    echo "N"
    echo "패스워드 최소 유효 기간이 설정되어 있지 않습니다 또는 0일입니다."
    echo "$pass_min_days_line"
fi

