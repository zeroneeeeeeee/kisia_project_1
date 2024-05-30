#!/bin/bash

# r_comm 변수를 선언하여 확인할 항목을 정의 한다.
r_comm=("rsh" "rlogin" "rexec" "shell" "login" "exec")
vulnerable=false

# -d 옵션을 주어 /etc/xinetd.d 디렉토리가 있는지 없는지 확인.
# for문으로 xinetd가 있다면 r_comm의 내용을 차례대로 확인한다.
if [ -d /etc/xinetd.d ]; then
    for ((i=0; i<${#r_comm[@]}; i++)); do
        # if문의 -f옵션은 파일이 존재하고 정규파일이면 참으로 xinetd가 존재한다는 가정하에 진행한다.
        if [ -f /etc/xinetd.d/${r_comm[$i]} ]; then
            etc_xinetdd_rcommand_disable_count=$(grep -vE '^#|^\s#' /etc/xinetd.d/${r_comm[$i]} | grep -i 'disable' | grep -i 'yes' | wc -l)
            if [ $etc_xinetdd_rcommand_disable_count -eq 0 ]; then
                echo "N"
                echo "불필요한 r 계열 서비스가 활성화 되어있습니다."
                vulnerable=true
            fi
        fi
    done
fi

# 파일이 xinetd가 아니라면 inetd.d가 존재하는지 확인.
if [ -f /etc/inetd.conf ]; then
    # 마찬가지로 for문을 돌려서 위와같은 여부를 판단
    for ((i=0; i<${#r_comm[@]}; i++)); do
        etc_inetdconf_rcommand_enable_count=$(grep -vE '^#|^\s#' /etc/inetd.conf | grep ${r_comm[$i]} | wc -l)
        if [ $etc_inetdconf_rcommand_enable_count -gt 0 ]; then
            echo "Vulnerable"
            echo "N"
            echo "불필요한 r 계열 서비스가 활성화 되어있습니다."
            vulnerable=true
        fi
    done
fi

# 비활성화인지 확인하는 구문으로 false이면 아래의 내용을 출력한다.
if [ "$vulnerable" = false ]; then
    echo "Y"
    echo "불필요한 r 계열 서비스가 비활성화 되어있습니다."
fi

L=$(ls -alL /etc/xinetd.d/* | egrep "rsh|rlogin|rexec")
echo "$L"
