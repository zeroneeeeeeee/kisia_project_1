#!/bin/sh

U_72() {

    touch result_3

    # syslog 파일 경로 설정
    if [ -f /etc/rsyslog.conf ]; then
        syslog_file="/etc/rsyslog.conf"
        echo "/etc/rsyslog.conf 파일이 존재합니다." > result_2
    elif [ -f /etc/syslog.conf ]; then
        syslog_file="/etc/syslog.conf"
        echo "/etc/syslog.conf 파일이 존재합니다." > result_2
    else
        echo "rsyslog.conf 또는 syslog.conf 파일이 존재하지 않습니다." > result_2
        
    fi

    # 설정 파일 내용 출력
    if [ -s "$syslog_file" ]; then
        cat "$syslog_file" | grep -v "^#" | grep -v '^$' > result_3
    else
        echo "$syslog_file 파일에 설정이 존재하지 않습니다." >> result_2
    fi

    # 설정 파일이 있으면 N/A 출력, 없으면 Y 출력
    if [ -s "$syslog_file" ]; then
        echo "N/A"
    else
        echo "Y"
    fi

    echo "$(cat result_2)"
    echo "$(cat result_3)"

    rm -rf result_2 result_3

}

U_72