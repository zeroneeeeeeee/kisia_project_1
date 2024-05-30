#!/bin/bash

file_exists_count=0
flag_count=0
text_arr=()
res_arr=()
res_Y_arr=()
if [ -f /etc/xinetd.conf ]; then
    ((file_exists_count++))
    etc_xinetconf_owner_name=`ls -l /etc/xinetd.conf | awk '{print $3}'`
    if [[ $etc_xinetconf_owner_name =~ root ]]; then
        etc_xinetconf_permission=`stat /etc/xinetd.conf | grep -i 'Uid' | awk '{print $2}' | awk -F "/" '{print substr($1,3,3)}'`
        if [[ $etc_xinetconf_permission -ne 600 ]]; then
            text_arr+=(/etc/xinetd.conf 파일의 권한이 600이 아닙니다.)
            res_arr+=(`stat /etc/xinetd.conf | grep -i 'Uid'`)
            ((flag_count++))
        fi
    else
        text_arr+=("/etc/xinetd.conf 파일의 소유자(owner)가 root가 아닙니다.")
        res_arr+=(`stat /etc/xinetd.conf | grep -i 'Uid'`)
        ((flag_count++))
    fi
fi

if [ -d /etc/xinetd.d ]; then
    etc_xinetdd_file_count=`find /etc/xinetd.d -type f 2>/dev/null | wc -l`
    if [ $etc_xinetdd_file_count -gt 0 ]; then
        xinetdd_file=(`find /etc/xinetd.d -type f 2>/dev/null`)
        for ((i=0; i<${#xinetdd_file[@]}; i++))
        do
            ((file_exists_count++))
            xinetdd_file_owner_name=`ls -l ${xinetdd_file[$i]} | awk '{print $3}'`
            if [[ $xinetdd_file_owner_name =~ root ]]; then
					xinetdd_file_permission=`stat ${xinetdd_file[$i]} | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,3,3)}'`
					if [ $xinetdd_file_permission -ne 600 ]; then
                        text_arr+=(/etc/xinetd.d 디렉터리 내 파일의 권한이 600이 아닙니다.)
                        res_arr+=(`ls -l ${xinetdd_file[$i]}; stat ${xinetdd_file[$i]} | grep -i 'Uid'`)
                        ((flag_count++))
                    fi
            else
                text_arr+=("/etc/xinetd.d 디렉터리 내 파일의 소유자(owner)가 root가 아닙니다.")
                res_arr+=(`ls -l ${xinetdd_file[$i]}; stat ${xinetdd_file[$i]} | grep -i 'Uid'`)
                ((flag_count++))
            fi
        done
    fi
fi

if [ -f /etc/inetd.conf ]; then
    ((file_exists_count++))
	etc_inetdconf_owner_name=`ls -l /etc/inetd.conf | awk '{print $3}'`
	if [[ $etc_inetdconf_owner_name =~ root ]]; then
		etc_inetdconf_permission=`stat /etc/inetd.conf | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,3,3)}'`
		if [ $etc_inetdconf_permission -ne 600 ]; then
            text_arr+=(/etc/inetd.conf 파일의 권한이 600이 아닙니다.)
            res_arr+=(`stat /etc/inetd.conf | grep -i 'Uid'`)
            ((flag_count++))
        fi
    else
        text_arr+=("/etc/inetd.conf 파일의 소유자(owner)가 root가 아닙니다.")
        res_arr+=(`stat /etc/inetd.conf | grep -i 'Uid'`)
        ((flag_count++))
    fi
fi


if [ $file_exists_count -eq 0 ]; then
	echo "N"
	echo "파일이 존재하지 않습니다."
    res_arr+=(`ls -l /etc/xinetd.conf; ls -l /etc/inetd.conf`)
    echo "${res_arr[@]}"
    ((flag_count++))
elif [ $file_exists_count -gt 0 ]; then
    echo "N"
    echo "${text_arr[@]}"
    echo "${res_arr[@]}"
    if [ $flag_count -eq 0 ]; then
        echo "Y"
        echo "파일이 존재하며, 파일의 권한이 양호합니다."
        res_Y_arr+=(`stat /etc/xinetd.conf | grep -i 'Uid'`)
        for ((i=0; i<${#xinetdd_file[@]}; i++))
        do
            res_Y_arr+=(`stat ${xinetdd_file[$i]} | grep -i 'Uid'`)
        done
        res_Y_arr+=(`stat /etc/inetd.conf | grep -i 'Uid'`)
        echo "${res_Y_arr[@]}"
    fi
fi