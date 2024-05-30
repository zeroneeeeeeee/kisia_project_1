#!/bin/bash

# 먼저 services를 변수로 선언해서 확인할 서비스를 정의한다.
# 그리고 xinetd와 inetd로 두개로 나눠서 검사하는데 grep 명령어를 사용.
#-f "/etc/xinetd.d/$service": /etc/xinetd.d 디렉토리에 해당 서비스 파일이 있는지 확인하고, ! grep -qE '^\s*disable\s*=\s*yes' "/etc/xinetd.d/$service": 해당 서비스 파일에서 "disable=yes"가 아닌 경우를 확인하여 서비스가 활성화되어 있는지 확인한다.

services=("tftp" "talk" "ntalk")
vulnerable=0

if [ -d /etc/xinetd.d ]; then
    for service in "${services[@]}"; do
        if [ -f "/etc/xinetd.d/$service" ] && ! grep -qE '^\s*disable\s*=\s*yes' "/etc/xinetd.d/$service"; then
            echo "N"
            echo "$service 가 /etc/xinetd.d 디렉토리 내에 서비스 파일에서 실행중입니다."
            vulnerable=1
        fi
    done
fi

if [ -f /etc/inetd.conf ]; then
    for service in "${services[@]}"; do
        if grep -qE "^\s*$service\s+" /etc/inetd.conf; then
            echo "N"
            echo "$service 가 /etc/inetd.d 디렉토리 내에 서비스 파일에서 실행중입니다."
            vulnerable=1
        fi
    done
fi

# $vulnerable -eq 0: 취약성을 나타내는 변수가 0인지 확인하여 모든 서비스가 비활성화되어 있는지 확인합니다.

if [ $vulnerable -eq 0 ]; then
    echo "Y"
    echo "서비스가 비활성화 중입니다."
fi

X=$(ls -l "xinetd.d | inetd.d")
echo "$X"