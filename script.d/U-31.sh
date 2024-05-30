#!/bin/bash

vulnerable=0

if grep -qE '^\s*smtp\s+.*tcp' /etc/services && netstat -nat 2>/dev/null | grep -qw 'tcp' && sendmailcf=$(find / -name 'sendmail.cf' -type f 2>/dev/null); then
    for cf in $sendmailcf; do
        if ! grep -qE '^\s*R\$\*\s*:\s*Relaying denied' "$cf"; then
            echo "N"
            echo "스팸 메일 릴레이 제한이 되어있지 않습니다."
            vulnerable=1
            break
        fi
    done
elif ps -ef | grep -qE 'smtp|sendmail' && sendmailcf=$(find / -name 'sendmail.cf' -type f 2>/dev/null); then
    for cf in $sendmailcf; do
        if ! grep -qE '^\s*R\$\*\s*:\s*Relaying denied' "$cf"; then
            echo "Vulnerable"
            echo "Y"
            vulnerable=1
            break
        fi
    done
fi

if [ $vulnerable -eq 0 ]; then
    echo "Y"
    echo "스팸 메일 릴레이 제한되어 있습니다."
fi
S=$(cat /etc/mail/sendmail.cf | grep "R$\*" | grep "Relaying denied")                                                     
echo "$S"