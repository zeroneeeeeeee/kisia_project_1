#!/bin/bash

flag_count=0
text_arr=()
res_arr=()
res_Y_arr=()
ps_telnet_count=`ps -ef | grep -i 'telnet' | grep -v 'grep' | wc -l`
if [ $ps_telnet_count -gt 0 ]; then
	if [ -f /etc/pam.d/login ]; then
		pam_securetty_so_count=`grep -vE '^#' /etc/pam.d/login | grep -i 'pam_securetty.so' | wc -l`
		if [ $pam_securetty_so_count -gt 0 ]; then
			if [ -f /etc/securetty ]; then
				etc_securetty_pts_count=`grep -vE '^#' /etc/securetty | grep -w 'pts' | wc -l`
				if [ $etc_securetty_pts_count -gt 0 ]; then
                    text_arr+=(telnet 서비스를 사용하고, /etc/securetty 파일에 pts 부분이 제거 또는 주석처리 되어 있지 않습니다.)
                    res_arr+=(`ps -ef | grep -i 'telnet' | grep -v 'grep'; cat /etc/securetty | grep -w 'pts'`)
                    ((flag_count++))
                fi
            else
                text_arr+=(telnet 서비스를 사용하고, /etc/securetty 파일이 없습니다.) 
                res_arr+=(`ps -ef | grep -i 'telnet' | grep -v 'grep'`)
                ((flag_count++))
            fi
        else
            text_arr+=(telnet 서비스를 사용하고, /etc/pam.d/login 파일에 pam_securetty.so 모듈이 제거 또는 주석 처리되어 있습니다.) 
            res_arr+=(`ps -ef | grep -i 'telnet' | grep -v 'grep'; cat /etc/pam.d/login | grep -i 'pam_securetty.so'`)
            ((flag_count++))
        fi
    else
        text_arr+=(telnet 서비스를 사용하고, /etc/pam.d/login 파일이 없습니다.) 
        res_arr+=(`ps -ef | grep -i 'telnet' | grep -v 'grep'`)
        ((flag_count++))
    fi
fi

ps_sshd_enable_count=`ps -ef | grep -i 'sshd' | grep -v 'grep' | wc -l`
if [ $ps_sshd_enable_count -gt 0 ]; then
    sshd_config_count=`find /etc/ssh -name sshd_config | wc -l` 
	if [ $sshd_config_count -eq 0 ]; then
		text_arr+=(ssh 서비스를 사용하고, sshd_config 파일이 없습니다.) 
        res_arr+=(`ps -ef | grep -i 'sshd' | grep -v 'grep'`)
        ((flag_count++))
	fi
	
    sshd_permitrootlogin_no_count=`grep -vE '^#' /etc/ssh/sshd_config | grep -i 'permitrootlogin' | grep -i 'no' | wc -l`
	if [ $sshd_permitrootlogin_no_count -eq 0 ]; then
        text_arr+=(ssh 서비스를 사용하고, sshd_config 파일에서 root 계정의 원격 접속이 허용되어 있습니다.) 
        res_arr+=(`ps -ef | grep -i 'sshd' | grep -v 'grep'; cat /etc/ssh/sshd_config | grep -i 'permitrootlogin'`)
        ((flag_count++))
	fi
fi


if [ $flag_count -eq 0 ]; then
    echo "Y"
    echo "telnet, ssh 서비스를 사용하지 않고, sshd_config 파일에서 root 계정의 원격 접속이 허용되어 있지 않습니다."
    res_Y_arr+=(`cat /etc/ssh/sshd_config | grep -i 'permitrootlogin'`)
    echo "${res_Y_arr[@]}"
else
    echo "N"
    echo "${text_arr[@]}"
    echo "${res_arr[@]}"
fi