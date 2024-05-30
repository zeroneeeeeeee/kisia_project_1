#!/bin/bash

finger_conf="/etc/finger.conf"

# if문에 -f옵션을 주어서 파일이 있으면 참 없으면 거짓을 써서 finger.cinf 파일이 존재하면 위험하다는 표시를 주었다.

if [ -f "$finger_conf" ] ; then
        echo "N"
        echo "Finger 서비스가 활성화 되어 있습니다."
else
        echo "Y"
        echo "Finger 서비스가 비활성화 되어 있습니다."
fi
L=$(ps -ef | grep "xinetd\|inetd" | ls -al /etc/xinetd.d/ /etc/inetd.d)
echo "$L"