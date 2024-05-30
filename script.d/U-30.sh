#!/bin/bash
# grep -q 옵션은 grep 명령어의 조용한 모드를 나타냅니다. 이 옵션을 사용하면 grep이 패턴을 찾았는지 여부에 따라 출력되는 내용이 변경

# sendmail 패키지가 설치되어 있는지 확인합니다.
if dpkg -s sendmail &>/dev/null; then
    # sendmail 패키지의 현재 버전을 가져옵니다.
    current_version=$(dpkg -s sendmail | awk '/Version:/ {print tolower($2)}')

    # 현재 버전이 '8.17.1'인지 확인합니다.
    if [ "$current_version" = "8.17.1" ]; then
        echo "Y"
        echo "U-30 : Sendmail 버전이 최신버전입니다."
    else
        echo "N"
        echo "U-30 : Sendmail 버전이 최신버전이 아닙니다."
    fi
else
    # sendmail 패키지가 설치되어 있지 않은 경우 'Y'와 메시지를 출력합니다.
    echo "Y"
    echo "sendmail이 최신 버전입니다."
fi

# sendmail 명령어를 사용하여 버전 정보를 가져옵니다.
sendmail_version=$(sendmail -d0.1 -bt < /dev/null 2>&1)

# sendmail 버전 정보가 포함되어 있는지 확인합니다.
sendmail_version=$(ps -ef | grep sendmail | dpkg -l sendmail)
echo "$sendmail_version"