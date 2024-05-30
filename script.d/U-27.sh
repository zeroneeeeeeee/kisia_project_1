#!/bin/bash

# 비활성화된 RPC 서비스를 확인하는 스크립트

# 비활성화된 RPC 서비스가 포함된 파일을 확인하는 함수
check_service() {
    if [ -f "$1" ] && grep -qE '^\s*disable\s*=\s*yes' "$1"; then
        echo "Y"
        echo "불필요한 RPC 서비스가 비활성화 되어 있습니다."
    fi
}

# /etc/xinetd.d 디렉토리에 있는 파일을 검사하여 RPC 서비스를 찾습니다.
if [ -d /etc/xinetd.d ]; then
    for service_file in /etc/xinetd.d/*; do
        for service in "${rpc_services[@]}"; do
            check_service "$service_file" "$service"
        done
    done
fi

# /etc/inetd.conf 파일에서 RPC 서비스를 찾습니다.
if [ -f /etc/inetd.conf ]; then
    for service in "${rpc_services[@]}"; do
        if grep -qE "^\s*$service\s+" /etc/inetd.conf; then
            echo "N"
            echo "불필요한 RPC 서비스가 활성화 되어 있습니다."
        fi
    done
fi

# 어떤 RPC 서비스도 활성화되어 있지 않은 경우
echo "Y"
echo "불필요한 RPC 서비스가 비활성화 되어 있습니다."

ls -l /etc/xinetd.d >> file2
ls -l /etc/inetd.conf >> file2
echo "$(cat file2)"

rm -rf file2