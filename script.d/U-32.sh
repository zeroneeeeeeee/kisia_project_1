#!/bin/bash

vulnerable=0

# SMTP 서비스가 활성화되어 있는지, 그리고 sendmail.cf 파일이 존재하는지 확인
if grep -qE '^\s*smtp\s+.*tcp' /etc/services && netstat -nat 2>/dev/null | grep -qw 'tcp' && sendmailcf=$(find / -name 'sendmail.cf' -type f 2>/dev/null); then
    # sendmail.cf 파일을 반복하여 검사
    for cf in $sendmailcf; do
        # sendmail.cf 파일에서 restrictqrun 옵션이 설정되어 있는지 확인
        if ! grep -qE 'privacyoptions=.*restrictqrun' "$cf"; then
            echo "N"
            echo "SMTP 서비스 사용 및 일반 사용자의 Sendmail 실행 방지가 설정되어 있지 않았습니다."
            vulnerable=1
            break
        fi
    done
# SMTP 서비스가 활성화되어 있거나, sendmail 프로세스가 실행 중인지 확인
elif ps -ef | grep -qE 'smtp|sendmail' && sendmailcf=$(find / -name 'sendmail.cf' -type f 2>/dev/null); then
    # sendmail.cf 파일을 반복하여 검사
    for cf in $sendmailcf; do
        # sendmail.cf 파일에서 restrictqrun 옵션이 설정되어 있는지 확인
        if ! grep -qE 'privacyoptions=.*restrictqrun' "$cf"; then
            echo "N"
            echo "SMTP 서비스 사용 및 일반 사용자의 Sendmail 실행 방지가 설정되어 있지 않았습니다."
            vulnerable=1
            break
        fi
    done
fi

# 취약점이 없는 경우 Y와 메시지를 출력합니다.
if [ $vulnerable -eq 0 ]; then
    echo "Y"
    echo "SMTP 서비스 미사용 또는, 일반 사용자의 Sendmail 실행 방지가 설정되어있습니다."
fi
SMTP=$(ps -ef | grep sendmail; ls /etc/mail/sendmail.cf)
echo "$SMTP"