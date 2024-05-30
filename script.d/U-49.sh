#!/bin/bash

# "U-49. 시스템 계정 중 불필요한 계정 존재 여부"

# 함수를 이용해 사용자가 존재하는지 확인
# grep -q : 결과를 화면에 출력하지 않음
# 대신 존재하면 0, 존재하지 않으면 1을 반환
user_exists() {
    grep -q "^$1:" /etc/passwd
}

# 취약점 분석 시작

# 사용하지 않는 Default 계정 리스트
default_accounts=("lp" "uucp" "nuucp")

# /etc/passwd 파일 존재 여부 확인
# if ! -f : 파일이 없으면 true 
if [ ! -f /etc/passwd ]; then
    echo "Y"
    echo "/etc/passwd 파일을 찾을 수 없습니다."
    result=$(ls /etc/passwd 2>/dev/null) # 에러 메시지를 무시
    echo "$result"
    # exit 1 를 제거
fi

# 취약점 분석 실행
vulnerable=false
vulnerable_accounts=""

for account in "${default_accounts[@]}"; do
    if user_exists "$account"; then
        vulnerable_accounts+="$account "
        vulnerable=true
    fi  
done

# 취약점 결과 출력
if [ "$vulnerable" = true ]; then
    echo "N"
    echo "불필요한 계정이 존재합니다. 해당 계정은 아래와 같습니다."
    echo "$vulnerable_accounts"
else
    echo "Y"
    echo "불필요한 계정이 존재하지 않습니다."
    echo "$vulnerable_accounts"
fi
