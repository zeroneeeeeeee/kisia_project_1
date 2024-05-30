#!/bin/bash

# /etc/passwd 파일의 경로
passwd_file="/etc/passwd"

# /etc/passwd 파일이 존재하는지 확인
if [ ! -f "$passwd_file" ]; then
    echo "Y"
    echo "/etc/passwd 파일을 찾을 수 없습니다"
    result=$(ls /etc/passwd 2>/dev/null)
    echo "$result"
    exit
fi

# UID=0인 계정을 찾되, root 계정은 제외
# awk -> /etc/passwd 파일 파싱, UID가 0이면서 사용자 이름이 root가 아닌 계정 찾기
# -F: -> 필드 구분자로 ':' 사용
# $3 == "0" -> 세 번째 필드인 UID가 0인 레코드를 찾기
# $1 != "root" -> 첫 번째 필드인 사용자 이름이 root가 아닌 것을 필터링
non_root_uid0_accounts=$(awk -F: '$3 == "0" && $1 != "root"' $passwd_file)

# UID=0인 non-root 계정의 존재 여부에 따라 결과 출력
if [ -z "$non_root_uid0_accounts" ]; then # if -z : 변수가 비어 있으면 true
    echo "Y"
    echo "root 계정과 동일한 UID를 갖는 계정이 존재하지 않습니다"
    echo "$non_root_uid0_accounts"
else
    echo "N"
    echo "root 계정과 동일한 UID를 갖는 계정이 존재합니다"
    echo "$non_root_uid0_accounts"
fi

