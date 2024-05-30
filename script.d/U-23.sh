#!/bin/bash

# 사용하지 않는 DoS 공격에 취약한 서비스 목록
services=$("echo" "discard" "daytime" "chargen")

# 취약 여부를 나타내는 플래그 초기화
vulnerable=0

# /etc/xinetd.d 디렉토리 확인
if [ -d /etc/xinetd.d ]; then
    # 각 서비스에 대해 반복하여 확인
    for service in "${services[@]}"; do
        # 서비스 파일이 존재하고 해당 서비스가 비활성화되어있지 않은지 확인
        if [ -f "/etc/xinetd.d/$service" ] && ! grep -qE '^\s*disable\s*=\s*yes' "/etc/xinetd.d/$service"; then
            # 취약한 서비스가 발견되면 해당 내용을 출력하고 취약 플래그 설정
            echo "N"
            echo "사용하지 않는 DoS 공격에 취약한 서비스가 활성화 된 경우"
            vulnerable=1
        fi
    done
fi

# /etc/inetd.conf 파일 확인
if [ -f /etc/inetd.conf ]; then
    # 각 서비스에 대해 반복하여 확인
    for service in "${services[@]}"; do
        # 해당 서비스가 활성화되어 있는지 확인
        if grep -qE "^\s*$service\s+" /etc/inetd.conf; then
            # 취약한 서비스가 발견되면 해당 내용을 출력하고 취약 플래그 설정
            echo "N"
            echo "사용하지 않는 DoS 공격에 취약한 서비스가 활성화 되어있습니다."
            vulnerable=1
        fi
    done
fi

# 취약 플래그가 설정되어 있지 않다면 해당 내용을 출력
if [ $vulnerable -eq 0 ]; then
    echo "Y"
    echo "사용하지 않는 DoS 공격에 취약한 서비스가 비활성화 되어있습니다."
fi

E=$(ls -l /etc/xinetd.d/ | grep enable)
echo "$E"
