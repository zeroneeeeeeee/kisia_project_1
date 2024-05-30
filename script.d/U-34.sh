#!/bin/bash

# DNS 서버 프로세스 확인 (named 외 다른 이름으로 실행 중인 경우도 포함)
ps_dns_count=$(ps -ef | grep -i 'named' | grep -v 'grep' | wc -l)

# 결과 초기화
allow_transfer_set="N"

if [ $ps_dns_count -gt 0 ]; then
    # named.conf 파일 경로 확인 (기본 경로 외 다른 경로에 있는 경우도 포함)
    named_conf_paths=$(find / -name named.conf -type f 2>/dev/null)
    if [ -n "$named_conf_paths" ]; then
        # named.conf 파일에서 allow-transfer 옵션 확인 (any 외 다른 설정도 포함)
        for named_conf_path in $named_conf_paths; do
            # allow-transfer 옵션이 설정된 경우 수를 세어보자.
            etc_namedconf_allowtransfer_count=$(grep -vE '^#|^\s#' "$named_conf_path" | grep -i 'allow-transfer' | wc -l)
            if [ $etc_namedconf_allowtransfer_count -gt 0 ]; then
                # allow-transfer 설정된 것이 발견되면 Y로 설정하고 루프 종료
                allow_transfer_set="Y"
                break
            fi
        done
    fi
fi

# 결과 출력
if [ "$allow_transfer_set" == "Y" ]; then
    echo "Y"
    echo "DNS 서비스 미사용 또는, Zone Transfer를 허가된 사용자에게만 허용하였습니다."
else
    echo "N"
    echo "DNS 서비스를 사용하며 Zone Transfer를 모든 사용자에게 허용하였습니다."
fi
