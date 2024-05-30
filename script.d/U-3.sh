#!/bin/bash

flag_count=0
text_arr=()
res_arr=()
res_Y_arr=()
file_exists_count=0
deny_file_exists_count=0
no_settings_in_deny_file=0
deny_modules=("pam_tally.so" "pam_tally2.so" "pam_faillock.so")

if [ -f /etc/pam.d/system-auth ]; then
    for ((i=0; i<${#deny_modules[@]}; i++))
    do
        etc_pamd_systemauth_deny_count=`grep -vE '^#' /etc/pam.d/system-auth | grep -i ${deny_modules[$i]} | grep -i 'deny' | wc -l`
        if [ $etc_pamd_systemauth_deny_count -eq 0 ]; then
            etc_pamd_systemauth_deny_value=`grep -vE '^#' /etc/pam.d/system-auth | grep -i ${deny_modules[$i]} | grep -i 'deny' | awk -F 'deny' '{gsub(" ", "", $0); print substr($2,2,1)}'`
            etc_pamd_systemauth_deny_second_value=`grep -vE '^#' /etc/pam.d/system-auth | grep -i ${deny_modules[$i]} | grep -i 'deny' | awk -F 'deny' '{gsub(" ", "", $0); print substr($2,3,1)}'`
            etc_pamd_systemauth_deny_third_value=`grep -vE '^#' /etc/pam.d/system-auth | grep -i ${deny_modules[$i]} | grep -i 'deny' | awk -F 'deny' '{gsub(" ", "", $0); print substr($2,4,1)}'`
            if [ $etc_pamd_systemauth_deny_value -eq 0 ]; then
					continue
			elif [ $etc_pamd_systemauth_deny_value -eq 1 ]; then
					if [[ $etc_pamd_systemauth_deny_second_value =~ [1-9] ]]; then                
                        text_arr+=(/etc/pam.d/system-auth 파일에 계정 잠금 임계값이 11회 이상으로 설정되어 있습니다.)
						res_arr+=(`cat /etc/pam.d/system-auth | grep -i ${deny_modules[$i]}`)
						((flag_count++))
					else
						if [[ $etc_pamd_systemauth_deny_third_value =~ [0-9] ]]; then                     
                            text_arr+=(/etc/pam.d/system-auth 파일에 계정 잠금 임계값이 11회 이상으로 설정되어 있습니다.)
							res_arr+=(`cat /etc/pam.d/system-auth | grep -i ${deny_modules[$i]}`)
							((flag_count++))
						fi
					fi
			else
				if [[ $etc_pamd_systemauth_deny_second_value =~ [0-9] ]]; then               
                    text_arr+=(/etc/pam.d/system-auth 파일에 계정 잠금 임계값이 11회 이상으로 설정되어 있습니다.)
					res_arr+=(`cat /etc/pam.d/system-auth | grep -i ${deny_modules[$i]}`)
					((flag_count++))
                fi
			fi
		else
			 etc_pamd_systemauth_comment_check=`grep -E '^#' /etc/pam.d/system-auth | grep -i ${deny_modules[$i]} | wc -l`
			if [ $etc_pamd_systemauth_comment_check -gt 0 ]; then
				text_arr+=(/etc/pam.d/system-auth 파일에 관련 설정이 주석처리 되어 있습니다.)
				res_arr+=(`cat /etc/pam.d/system-auth | grep -i ${deny_modules[$i]}`)
				((flag_count++))
			fi
			((no_settings_in_deny_file++))
		fi
	done
fi

if [ -f /etc/pam.d/common-auth ]; then
	((file_exists_count++))
	for ((i=0; i<${#deny_modules[@]}; i++))
	do
		((deny_file_exists_count++))
		etc_pamd_commonauth_deny_count=`grep -vE '^#' /etc/pam.d/common-auth | grep -i ${deny_modules[$i]} | grep -i 'deny' | wc -l`
		if [ $etc_pamd_commonauth_deny_count -gt 0 ]; then
			etc_pamd_commonauth_deny_value=`grep -vE '^#' /etc/pam.d/common-auth | grep -i ${deny_modules[$i]} | grep -i 'deny' | awk -F 'deny' '{gsub(" ", "", $0); print substr($2,2,1)}'`
			etc_pamd_commonauth_deny_second_value=`grep -vE '^#' /etc/pam.d/common-auth | grep -i ${deny_modules[$i]} | grep -i 'deny' | awk -F 'deny' '{gsub(" ", "", $0); print substr($2,3,1)}'`
			etc_pamd_commonauth_deny_third_value=`grep -vE '^#' /etc/pam.d/common-auth | grep -i ${deny_modules[$i]} | grep -i 'deny' | awk -F 'deny' '{gsub(" ", "", $0); print substr($2,4,1)}'`
			if [ $etc_pamd_commonauth_deny_value -eq 0 ]; then
				continue
			elif [ $etc_pamd_commonauth_deny_value -eq 1 ]; then
				if [[ $etc_pamd_commonauth_deny_second_value =~ [1-9] ]]; then               
                    text_arr+=(/etc/pam.d/common-auth 파일에 계정 잠금 임계값이 11회 이상으로 설정되어 있습니다.)
					res_arr+=(`cat /etc/pam.d/common-auth | grep -i ${deny_modules[$i]}`)
					((flag_count++))
				else
				    if [[ $etc_pamd_commonauth_deny_third_value =~ [0-9] ]]; then                  
                        text_arr+=(/etc/pam.d/common-auth 파일에 계정 잠금 임계값이 11회 이상으로 설정되어 있습니다.)
						res_arr+=(`cat /etc/pam.d/common-auth | grep -i ${deny_modules[$i]}`)
						((flag_count++))
					fi
				fi
			else
				if [[ $etc_pamd_commonauth_deny_second_value =~ [0-9] ]]; then               
                    text_arr+=(/etc/pam.d/common-auth 파일에 계정 잠금 임계값이 11회 이상으로 설정되어 있습니다.)
					res_arr+=(`cat /etc/pam.d/common-auth | grep -i ${deny_modules[$i]}`)
					((flag_count++))
				fi
			fi
		else
			etc_pamd_commonauth_comment_check=`grep -E '^#' /etc/pam.d/common-auth | grep -i ${deny_modules[$i]} | wc -l`
			if [ $etc_pamd_commonauth_comment_check -gt 0 ]; then
				text_arr+=(/etc/pam.d/common-auth  파일에 관련 설정이 주석처리 되어 있습니다.)
				res_arr+=(`cat /etc/pam.d/common-auth  | grep -i ${deny_modules[$i]}`)
				((flag_count++))
			fi
			((no_settings_in_deny_file++))
		fi
	done
fi

if [ -f /etc/pam.d/common-password ]; then
	((file_exists_count++))
	for ((i=0; i<${#deny_modules[@]}; i++))
	do
		((deny_file_exists_count++))
		etc_pamd_commonpasswd_deny_count=`grep -vE '^#' /etc/pam.d/common-password | grep -i ${deny_modules[$i]} | grep -i 'deny' | wc -l`
		if [ $etc_pamd_commonpasswd_deny_count -gt 0 ]; then
		    etc_pamd_commonpasswd_deny_value=`grep -vE '^#' /etc/pam.d/common-password | grep -i ${deny_modules[$i]} | grep -i 'deny' | awk -F 'deny' '{gsub(" ", "", $0); print substr($2,2,1)}'`
			etc_pamd_commonpasswd_deny_second_value=`grep -vE '^#' /etc/pam.d/common-password | grep -i ${deny_modules[$i]} | grep -i 'deny' | awk -F 'deny' '{gsub(" ", "", $0); print substr($2,3,1)}'`
			etc_pamd_commonpasswd_deny_third_value=`grep -vE '^#' /etc/pam.d/common-password | grep -i ${deny_modules[$i]} | grep -i 'deny' | awk -F 'deny' '{gsub(" ", "", $0); print substr($2,4,1)}'`
			if [ $etc_pamd_commonpasswd_deny_value -eq 0 ]; then
				continue
			elif [ $etc_pamd_commonpasswd_deny_value -eq 1 ]; then
					if [[ $etc_pamd_commonpasswd_deny_second_value =~ [1-9] ]]; then                    
                        text_arr+=(/etc/pam.d/common-password 파일에 계정 잠금 임계값이 11회 이상으로 설정되어 있습니다.)
						res_arr+=(`cat /etc/pam.d/common-password | grep -i ${deny_modules[$i]}`)
						((flag_count++))
					else
						if [[ $etc_pamd_commonpasswd_deny_third_value =~ [0-9] ]]; then                       
                            text_arr+=(/etc/pam.d/common-password 파일에 계정 잠금 임계값이 11회 이상으로 설정되어 있습니다.)
							res_arr+=(`cat /etc/pam.d/common-password | grep -i ${deny_modules[$i]}`)
							((flag_count++))
						fi
					fi
			else
				if [[ $etc_pamd_commonpasswd_deny_second_value =~ [0-9] ]]; then               
                    text_arr+=(/etc/pam.d/common-password 파일에 계정 잠금 임계값이 11회 이상으로 설정되어 있습니다.)
					res_arr+=(`cat /etc/pam.d/common-password | grep -i ${deny_modules[$i]}`)
					((flag_count++))
				fi
			fi
		else
			etc_pamd_commonpasswd_comment_check=`grep -E '^#' /etc/pam.d/common-password | grep -i ${deny_modules[$i]} | wc -l`
			if [ $etc_pamd_commonpasswd_comment_check -gt 0 ]; then
				text_arr+=(/etc/pam.d/common-password 파일에 관련 설정이 주석처리 되어 있습니다.)
				res_arr+=(`cat /etc/pam.d/common-password | grep -i ${deny_modules[$i]}`)
				((flag_count++))
			fi
			((no_settings_in_deny_file++))
		fi
	done
fi
if [ $file_exists_count -eq 0 ]; then
    text_arr+=(계정 잠금 임계값을 설정하는 파일이 없습니다.)
	((flag_count++))
elif [ $deny_file_exists_count -eq $no_settings_in_deny_file ]; then
    text_arr+=(계정 잠금 임계값을 설정한 파일이 없습니다.)
	for ((i=0; i<${#deny_modules[@]}; i++))
	do
	res_arr+=(`cat /etc/pam.d/system-auth 2>/dev/null | grep -i ${deny_modules[$i]}; cat /etc/pam.d/common-auth 2>/dev/null | grep -i ${deny_modules[$i]} | grep -i 'deny'; grep -vE '^#' /etc/pam.d/common-password 2>/dev/null | grep -i ${deny_modules[$i]} | grep -i 'deny'`)
	((flag_count++))
	done
fi

if [ $flag_count -eq 0 ]; then
	echo "Y"
	echo "계정 잠금 임계값의 설정 파일이 존재하며, 설정이 양호합니다."
	if [ -f /etc/pam.d/system-auth ]; then
		for ((i=0; i<${#deny_modules[@]}; i++))
    	do
			res_Y_arr+=(`cat /etc/pam.d/system-auth | grep -i ${deny_modules[$i]}`)
		done
	fi

	if [ -f /etc/pam.d/common-auth ]; then
		for ((i=0; i<${#deny_modules[@]}; i++))
    	do
			res_Y_arr+=(`cat /etc/pam.d/common-auth | grep -i ${deny_modules[$i]}`)
		done
	fi

	if [ -f /etc/pam.d/common-password ]; then
		for ((i=0; i<${#deny_modules[@]}; i++))
    	do
			res_Y_arr+=(`cat /etc/pam.d/common-password | grep -i ${deny_modules[$i]}`)
		done
	fi
	echo "${res_Y_arr[@]}"
else
	echo "N"
    echo "${text_arr[@]}"
    echo "${res_arr[@]}"
fi