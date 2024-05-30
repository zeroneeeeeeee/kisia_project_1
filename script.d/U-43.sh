#!/bin/bash

# "U-43. 로그의 정기적 검토 및 보고 여부 점검"

# 결과를 저장할 변수들을 초기화합니다.
result1=""
result2=""
result3=""

# 최근 로그인 및 실패한 로그인 시도를 확인합니다.
check_login_logs() {
    login=$(last | head -n 1)  # 가장 최근 로그인
    failed_login=$(lastb 2>/dev/null | head -n 1)  # 가장 최근 실패한 로그인, 표준 에러도 포>함
    result1="1) 최근 로그인 및 실패한 로그인 시도:\n$login\n$failed_login"
}

# 무단 su 시도를 확인합니다.
check_su_logs() {
    if [ -e /var/log/sulog ]; then
        su_attempt=$(grep 'SU ' /var/log/sulog)
        if [ -z "$su_attempt" ]; then
            result2="2) 무단 su 시도:\n무단 su 시도를 찾을 수 없습니다."
        else
            result2="2) 무단 su 시도:\n$su_attempt"
        fi
    else
        result2="2) 무단 su 시도:\n/var/log/sulog 파일을 찾을 수 없습니다. 데이터를 사
용할 수 없습니다."
    fi
}

# 무단 FTP 접속을 확인합니다.
check_ftp_logs() {
    if [ -e /var/log/xferlog ]; then
        unauthorized_ftp=$(grep 'unauthorized' /var/log/xferlog)
        if [ -z "$unauthorized_ftp" ]; then
            result3="3) 무단 FTP 접속:\n무단 FTP 접속을 찾을 수 없습니다."
        else
            result3="3) 무단 FTP 접속:\n$unauthorized_ftp"
        fi
    else
        result3="3) 무단 FTP 접속:\n/var/log/xferlog 파일을 찾을 수 없습니다. 데이터를
 사용할 수 없습니다."
    fi
}

# 주요 기능
main() {
    check_login_logs
    check_su_logs
    check_ftp_logs
    echo "N/A"
    echo "로그의 정기적 검토 및 보고 여부 확인"
    echo -e "$result1\n\n$result2\n\n$result3"
}

main
