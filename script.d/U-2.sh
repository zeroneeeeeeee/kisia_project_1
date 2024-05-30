#!/bin/bash
flag_count=0
text_arr=()
res_arr=()
res_Y_arr=()
input_options=("lcredit" "ucredit" "dcredit" "ocredit")
input_modules=("pam_pwquality.so" "pam_cracklib.so")
	
if [ -f /etc/login.defs ]; then
	res_Y_arr+=(`ls -l /etc/login.defs`)
	etc_logindefs_minlen_count=`grep -vE '^#' /etc/login.defs  | grep -i 'PASS_MIN_LEN' | awk '{print $2}' | wc -l`
	if [ $etc_logindefs_minlen_count -gt 0 ]; then
		etc_logindefs_minlen_value=`grep -vE '^#' /etc/login.defs  | grep -i 'PASS_MIN_LEN' | awk '{print $2}'`
		if [ $etc_logindefs_minlen_value -lt 8 ]; then 			
            text_arr+=("/etc/login.defs 파일에 최소 길이(PASS_MIN_LEN)가 8 미만으로 설정되어 있습니다.")
            res_arr+=(`cat /etc/login.defs  | grep -i 'PASS_MIN_LEN'`)
			((flag_count++))
		fi
	else
		etc_logindefs_comment_check=`grep -E '^#' /etc/login.defs | grep -i 'PASS_MIN_LEN' | wc -l`
		if [ $etc_logindefs_comment_check -gt 0 ]; then
			text_arr+=("/etc/login.defs 파일에 최소 길이(PASS_MIN_LEN)가 주석처리 되어 있습니다.")
            res_arr+=(`cat /etc/login.defs  | grep -i 'PASS_MIN_LEN'`)
			((flag_count++))
		fi
	fi
fi
	
if [ -f /etc/security/pwquality.conf ]; then
	res_Y_arr+=(`ls -l /etc/security/pwquality.conf`)
	etc_security_pwqualityconf_minlen_count=`grep -vE '^#' /etc/security/pwquality.conf  | grep -i 'minlen' | wc -l`
	if [ $etc_security_pwqualityconf_minlen_count -gt 0 ]; then
		etc_security_pwqualityconf_minlen_value=`grep -vE '^#' /etc/security/pwquality.conf  | grep -i 'minlen' | awk -F 'minlen' '{gsub(" ", "", $0); print substr($2,2,1)}'`
		if [ $etc_security_pwqualityconf_minlen_value -lt 8 ]; then
			etc_security_pwqualityconf_minlen_second_value=`grep -vE '^#' /etc/security/pwquality.conf  | grep -i 'minlen' | awk -F 'minlen' '{gsub(" ", "", $0); print substr($2,3,1)}'`
			if [[ $etc_security_pwqualityconf_minlen_second_value != [0-9] ]]; then  				
    			text_arr+=("/etc/security/pwquality.conf 파일에 최소 길이(minlen)가 8 미만으로 설정되어 있습니다.")
				res_arr+=(`cat /etc/security/pwquality.conf  | grep -i 'minlen'`)
				((flag_count++))
			fi
		else
			if [ -f /etc/pam.d/common-password ]; then
				res_Y_arr+=(`ls -l /etc/pam.d/common-password`)
				etc_pamd_commonpassword_module_count=`grep -vE '^#' /etc/pam.d/common-password | grep -i 'pam_pwquality.so' | wc -l`
				if [ $etc_pamd_commonpassword_module_count -eq 0 ]; then  					
					text_arr+=("/etc/security/pwquality.conf 파일에 최소 길이(minlen)를 8 이상으로 설정하고, /etc/pam.d/common-password 파일에 pam_pwquality.so 모듈을 추가하지 않았습니다.")
					res_arr+=(`cat /etc/security/pwquality.conf  | grep -i 'minlen'; cat /etc/pam.d/common-password | grep -i 'pam_pwquality.so'`)
					((flag_count++))
				fi
			else				
				text_arr+=("/etc/security/pwquality.conf 파일에 최소 길이(minlen)를 8 이상으로 설정했으나, /etc/pam.d/common-password 파일이 존재하지 않습니다.")
				res_arr+=(`cat /etc/pam.d/common-password | cat 'pam_pwquality.so'; ls -l /etc/pam.d/common-password`)
				((flag_count++))
			fi
		fi
	else
		etc_security_pwqualityconf_comment_check=`grep -E '^#' /etc/pam.d/common-password | grep -i 'minlen' | wc -l`
		if [ $etc_security_pwqualityconf_comment_check -gt 0 ]; then
			text_arr+=("/etc/security/pwquality.conf 파일에 최소 길이(minlen)가 주석처리 되어 있습니다.")
            res_arr+=(`cat /etc/security/pwquality.conf  | grep -i 'minlen'`)
			((flag_count++))
		fi	
	fi 

	for ((i=0; i<${#input_options[@]}; i++))
	do
		etc_security_pwqualityconf_mininput_count=`grep -vE '^#' /etc/security/pwquality.conf | grep -i ${input_options[$i]} | wc -l`
		if [ $etc_security_pwqualityconf_mininput_count -gt 0 ]; then
			etc_security_pwqualityconf_mininput_dash=`grep -vE '^#' /etc/security/pwquality.conf | grep -i ${input_options[$i]} | awk -F ${input_options[$i]} '{gsub(" ", "", $0); print substr($2,2,1)}'`
			if [[ $etc_security_pwqualityconf_mininput_dash =~ - ]]; then
				etc_security_pwqualityconf_mininput_value=`grep -vE '^#' /etc/security/pwquality.conf | grep -i ${input_options[$i]} | awk -F ${input_options[$i]} '{gsub(" ", "", $0); print substr($2,3,1)}'`
				if [ $etc_security_pwqualityconf_mininput_value -ge 1 ]; then
					if [ -f /etc/pam.d/common-password ]; then
						etc_pamd_commonpassword_module_count=`grep -vE '^#' /etc/pam.d/common-password | grep -i 'pam_pwquality.so' | wc -l`
						if [ $etc_pamd_commonpassword_module_count -eq 0 ]; then							
							text_arr+=(/etc/security/pwquality.conf 파일에 영문, 숫자, 특수문자의 최소 입력을 설정하고, /etc/pam.d/common-password 파일에 pam_pwquality.so 모듈을 추가하지 않았습니다.)
							res_arr+=(`cat '^#' /etc/pam.d/common-password | grep -i 'pam_pwquality.so'`)
							((flag_count++))
						fi
					else						
						text_arr+=(/etc/security/pwquality.conf 파일에 영문, 숫자, 특수문자의 최소 입력을 설정하고, /etc/pam.d/common-password 파일에 pam_pwquality.so 모듈을 추가하지 않았습니다.)
						res_arr+=(`cat /etc/security/pwquality.conf | grep -i ${input_options[$i]}`)
						((flag_count++))
					fi
				else					
					text_arr+=(/etc/security/pwquality.conf 파일에 영문, 숫자, 특수문자의 최소 입력이 1 미만으로 설정되어 있습니다.)
					res_arr+=(`cat /etc/security/pwquality.conf | grep -i ${input_options[$i]}`)
					((flag_count++))
				fi
			else				
				text_arr+=(/etc/security/pwquality.conf 파일에 영문, 숫자, 특수문자의 최소 입력에 대한 설정이 없습니다.)
				res_arr+=(`cat /etc/security/pwquality.conf | grep -i ${input_options[$i]}`)
				((flag_count++))
			fi
		else
			etc_security_pwqualityconf_mininput_comment_check=`grep -E '^#' /etc/security/pwquality.conf | grep -i ${input_options[$i]} | wc -l`
			if [ $etc_security_pwqualityconf_mininput_comment_check -eq 1 ]; then
				text_arr+=("/etc/security/pwquality.conf 파일에 영문, 숫자, 특수문자의 최소 입력 설정이 주석처리 되어 있습니다.")
            	res_arr+=(`cat /etc/security/pwquality.conf | grep -i ${input_options[$i]}`)
				((flag_count++))
			fi
		fi
	done
fi
if [ -f /etc/pam.d/common-password ]; then
	for ((i=0; i<${#input_modules[@]}; i++))
	do
		etc_pamd_commonpassword_minlen_count=`grep -vE '^#' /etc/pam.d/common-password | grep -i 'minlen' | grep -i ${input_modules[$i]} | wc -l`
		if [ $etc_pamd_commonpassword_minlen_count -gt 0 ]; then
			etc_pamd_commonpassword_minlen_value=`grep -vE '^#' /etc/pam.d/common-password | grep -i 'minlen' | grep -i ${input_modules[$i]} | awk '{gsub(" ", "", $0); print}' | awk -F 'minlen' '{print substr($2,2,1)}'`
			if [ $etc_pamd_commonpassword_minlen_value -lt 8 ]; then
				etc_pamd_commonpassword_minlen_second_value=`grep -vE '^#' /etc/pam.d/common-password | grep -i 'minlen' | grep -i ${input_modules[$i]} | awk '{gsub(" ", "", $0); print}' | awk -F 'minlen' '{print substr($2,3,1)}'`
				if [[ $etc_pamd_commonpassword_minlen_second_value != [0-9] ]]; then					
					text_arr+=("/etc/pam.d/common-password 파일에 최소 길이(minlen)가 8 미만으로 설정되어 있습니다.")
					res_arr+=(`cat /etc/pam.d/common-password | grep -i 'minlen' | grep -i ${input_modules[$i]}`)
					((flag_count++))
				fi
			fi
		else
			etc_pamd_commonpassword_minlen_comment_check=`grep -E '^#' /etc/pam.d/common-password | grep -i ${input_modules[$i]} | wc -l`
			if [ $etc_pamd_commonpassword_minlen_comment_check -eq 1 ]; then
				text_arr+=("/etc/pam.d/common-password 파일에 최소 길이(minlen) 설정이 주석처리 되어 있습니다.")
            	res_arr+=(`cat /etc/pam.d/common-password | grep -i ${input_modules[$i]}`)
				((flag_count++))
			fi
		fi
	done
	for ((i=0; i<${#input_modules[@]}; i++))
	do
		for ((j=0; j<${#input_options[@]}; j++))
		do
			etc_pamd_commonpassword_mininput_count=`grep -vE '^#' /etc/pam.d/common-password | grep -i ${input_options[$j]} | grep -i ${input_modules[$i]} | wc -l`
			if [ $etc_pamd_commonpassword_mininput_count -gt 0 ]; then
				etc_pamd_commonpassword_mininput_dash=`grep -vE '^#' /etc/pam.d/common-password | grep -i ${input_options[$j]} | grep -i ${input_modules[$i]} | awk -F ${input_options[$j]} '{gsub(" ", "", $0); print substr($2,2,1)}'`
				if [[ $etc_pamd_commonpassword_mininput_dash =~ - ]]; then
					etc_pamd_commonpassword_mininput_number=`grep -vE '^#' /etc/pam.d/common-password | grep -i ${input_options[$j]} | grep -i ${input_modules[$i]} | awk -F ${input_options[$j]} '{gsub(" ", "", $0); print substr($2,3,1)}'`
					if [ $etc_pamd_commonpassword_mininput_number -lt 1 ]; then						
						text_arr+=(/etc/pam.d/common-password 파일에 영문, 숫자, 특수문자의 최소 입력이 1 미만으로 설정되어 있습니다.)
						res_arr+=(`cat /etc/pam.d/common-password | grep -i ${input_options[$j]} | grep -i ${input_modules[$i]}`)
						((flag_count++))
					fi
				else				
					text_arr+=(/etc/pam.d/common-password 파일에 영문, 숫자, 특수문자의 최소 입력이 설정되어 있지 않습니다.)
					res_arr+=(`cat /etc/pam.d/common-password | grep -i ${input_options[$j]} | grep -i ${input_modules[$i]}`)
					((flag_count++))
				fi
			else
				etc_pamd_commonpassword_minlen_comment_check=`grep -E '^#' /etc/pam.d/common-password | grep -i ${input_options[$j]} | grep -i ${input_modules[$i]} | wc -l`
				if [ $etc_pamd_commonpassword_minlen_comment_check -eq 1 ]; then
					text_arr+=("/etc/pam.d/common-password 파일에 영문, 숫자, 특수문자의 최소 입력 설정이 주석처리 되어 있습니다.")
            		res_arr+=(`cat /etc/pam.d/common-password | grep -i ${input_options[$j]} | grep -i ${input_modules[$i]}`)
					((flag_count++))
				fi
			fi
		done
	done
fi

if [ $flag_count -eq 0 ]; then
	echo "Y"
	echo "패스워드 설정 파일이 존재하며, 패스워드 복잡성이 양호합니다."
	if [ -f /etc/login.defs ]; then
		res_Y_arr+=(`cat /etc/login.defs  | grep -i 'PASS_MIN_LEN'`)
	fi

	if [ -f /etc/security/pwquality.conf ]; then
		res_Y_arr+=(`cat /etc/security/pwquality.conf  | grep -i 'minlen'`)
	fi 
	
	if [ -f /etc/pam.d/common-password ]; then
		res_Y_arr+=(`cat /etc/pam.d/common-password | grep -i 'pam_pwquality.so'`)
		for ((i=0; i<${#input_modules[@]}; i++))
		do
			res_Y_arr+=(`cat /etc/pam.d/common-password | grep -i 'minlen' | grep -i ${input_modules[$i]}`)
			for ((j=0; j<${#input_options[@]}; j++))
			do
				res_Y_arr+=(`cat /etc/pam.d/common-password | grep -i ${input_options[$j]} | grep -i ${input_modules[$i]}`)
			done
		done
	fi
	echo "${res_Y_arr[@]}"
else
	echo "N"
    echo "${text_arr[@]}"
    echo "${res_arr[@]}"
fi