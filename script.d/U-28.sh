#!/bin/bash

NIS=()
# pgrep은 지정된 패턴을 갖는 프로세스의 수를 세는데, -f 옵션은 전체 명령어를 확인하고 -c 옵션은 프로세스 수를 돌려준다.

if pgrep -fc "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated" > 0; then
        echo "N"
        echo "NIS 서비스가 활성화 되어있습니다."
else
        echo "Y"
        echo "NIS 서비스가 비활성화 되어있습니다."
fi
NIS+=(`ls -al /etc/rc*.d/*`)
echo "${NIS[@]}"
            