#!/bin/bash

# /etc/login.defs 파일을 열어서 PASS_MIN_LEN 값을 확인하여 양호 또는 취약 여부를 판단하는 스크립트
# "U-46. 시스템 정책에 따라 비밀번호 길이 설정 적용 여부"

# /etc/login.defs 파일 경로
login_defs_file="/etc/login.defs"

# /etc/login.defs 파일 존재 여부 확인
if [ ! -f $login_defs_file ]; then
    echo "Y"
    echo "/etc/login.defs를 찾을 수 없습니다."
    result=$(ls $login_defs_file  2>/dev/null) #2>&1)
    echo "$result"
    # exit 1
fi

# PASS_MIN_LEN 설정의 전체 줄 가져오기
pass_min_len_line=$(grep "^PASS_MIN_LEN" $login_defs_file)

# PASS_MIN_LEN 설정 여부 확인
if [[ -z $pass_min_len_line ]]; then
    echo "N"
    echo "패스워드 최소 길이를 확인할 수 없습니다."
    echo "$pass_min_len_line"
else
    # PASS_MIN_LEN 값 추출
    pass_min_len=$(echo $pass_min_len_line | awk '{print $2}')
    # PASS_MIN_LEN이 8 이상인지 확인하여 결과 출력
    if [[ $pass_min_len -ge 8 ]]; then
        echo "Y"
        echo "패스워드 최소 길이가 8자 이상으로 설정되어 있습니다."
        echo "$pass_min_len_line"
    else
        echo "N"
        echo "패스워드 최소 길이가 8자 미만으로 설정되어 있습니다."
        echo "$pass_min_len_line"
    fi  
fi

