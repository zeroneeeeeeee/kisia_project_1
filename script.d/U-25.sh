#!/bin/bash

# /etc/exports 파일이 존재 여부 확인
if [ ! -f "/etc/exports" ]; then
    echo "Y"
    echo "Error : /etc/exports 파일을 찾을 수 없습니다."
    echo "존재하지않으므로 상태는 양호합니다."
else
    # /etc/exports 파일에서 "everyone" 공유 여부 확인
    if grep -q "everyone" "/etc/exports"; then
        echo "N"
        echo "불필요한 NFS 서비스를 사용하고 있고, everyone 공유를 제한하지 않았습니다."
    else
        echo "Y"
        echo "불필요한 NFS 서비스를 사용하지 않거나, 불가피하게 사용 시 everyone 공유를 제한하였습니다."
    fi
fi

# /etc/exports 파일의 내용 출력
if [ -f "/etc/exports" ]; then
    E=$(cat /etc/exports)
    echo "$E"
fi
