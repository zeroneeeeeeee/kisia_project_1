#!/bin/bash

##############################
##############################


U_56() {

	touch result_1

    #/etc/profile 파일
    if [ -f /etc/profile ]; then
        umask_profile=$(grep -i umask /etc/profile | grep -v "^#" | awk '{print $NF}')
        if [ -n "$umask_profile" ]; then
            if [ "$umask_profile" -lt "022" ]; then
                echo "/etc/profile 파일의 UMASK 값이 $umask_profile 로 022 이하입니다." >> result_2
                echo "BAD" > result_1
            else
                echo "/etc/profile 파일의 UMASK 값이 $umask_profile 로 022 이상입니다." >> result_2
                echo "GOOD" >> result_1
            fi
        else
            echo "/etc/profile 파일에 UMASK 설정이 없습니다." >> result_2
        fi
    else
        echo "/etc/profile 파일이 존재하지 않습니다." >> result_2
    fi

    #/etc/bashrc 파일
    if [ -f /etc/bashrc ]; then
        umask_bashrc=$(grep -i umask /etc/bashrc | grep -v "^#" | awk '{print $NF}')
        if [ -n "$umask_bashrc" ]; then
            if [ "$umask_bashrc" -lt "022" ]; then
                echo "/etc/bashrc 파일의 UMASK 값이 $umask_bashrc 이하입니다." >> result_2
                echo "BAD" > result_1
            else
                echo "/etc/bashrc 파일의 UMASK 값이 $umask_bashrc 이상입니다." >> result_2
                echo "GOOD" >> result_1
            fi
        else
            echo "/etc/bashrc 파일에 UMASK 설정이 없습니다." >> result_2
        fi
    else
        echo "/etc/bashrc 파일이 존재하지 않습니다." >> result_2
    fi
     
    # /etc/csh.cshrc 파일
    if [ -f /etc/csh.cshrc ]; then
        umask_csh=$(grep -i umask /etc/csh.cshrc | grep -v "^#" | awk '{print $NF}')
        if [ -n "$umask_csh" ]; then
            if [ "$umask_csh" -lt "022" ]; then
                echo "/etc/csh.cshrc 파일의 UMASK 값이 $umask_csh 이하입니다." >> result_2
                echo "BAD" > result_1
            else
                echo "/etc/csh.cshrc 파일의 UMASK 값이 $umask_csh 이상입니다." >> result_2
                echo "GOOD" >> result_1
            fi
        else
            echo "/etc/csh.cshrc 파일에 UMASK 설정이 없습니다." >> result_2
        fi
    else
        echo "/etc/csh.cshrc 파일이 존재하지 않습니다."  >> result_2
    fi

    if [ `cat result_1 | grep "BAD" | wc -l` -eq 0 ]; then
        echo "Y" #양호
    else
        echo "N" #취약
    fi

    echo "$(cat result_2)"

    cat /etc/profile | grep -i umask | grep -v "^#" >> result_3
    cat /etc/bashrc | grep -i umask | grep -v "^#" >> result_3
    cat /etc/csh.cshrc | grep -i umask | grep -v "^#" >> result_3

    echo "$(cat result_3)"

    rm -rf result_1 result_2 result_3

}
U_56

