#!/bin/bash

# "U-52. /etc/passwd 파일 내 UID가 동일한 사용자 계정 존재 여부 점검"

# /etc/passwd 파일의 존재 여부 확인
if [ ! -f /etc/passwd ]; then
    result=$(ls /etc/passwd 2>/dev/null) # 2>&1 : 표준 에러를 표준 출력으로 리디렉션
    echo "Y"
    echo "동일한 UID를 갖는 사용자 계정 존재 여부를 확인할 수 없습니다."
    echo "$result"
    # exit 0
fi

# 사용자 계정의 UID를 추출하고 중복된 UID를 찾음
# cut -d ':' -f /etc/passwd : cut을 사용해 /etc/passwd 파일에서 각 라인의 세 번째 필드인 UID 추출 -> 필드를 ':'로 구분할 수 있음
# sort -n : 추출된 UID를 숫자 기준으로 정렬
# uniq -d : 연속적으로 중복된 라인만 출력 -> 중복된 UID만 찾을 수 있음
uids=$(cut -d ':' -f 3 /etc/passwd | sort -n | uniq -d)

# 중복된 UID가 있는지 여부 확인
if [ -z "$uids" ]; then # if -z : 변수가 비어있으면 참
    echo "Y"
    echo "동일한 UID를 갖는 사용자 계정이 존재하지 않습니다."
    echo "$uids"
else
    echo "N"
    echo "동일한 UID를 갖는 사용자 계정이 존재합니다."
    echo "$uids"
    # awk를 사용하여 중복 UID를 가진 모든 계정 이름을 /etc/passwd에서 찾고 출력 -> '|'를 통해 UID를 구분
    awk -F: '$3 ~ /^('"${uids// /|}"')$/{print $1}' /etc/passwd
fi

