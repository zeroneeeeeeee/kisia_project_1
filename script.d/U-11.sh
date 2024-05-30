#!/bin/bash

syslogconf_files=("/etc/rsyslog.conf" "/etc/syslog.conf" "/etc/syslog-ng.conf")
file_exists_count=0
text_arr=()
res_arr=()
res_Y_arr=()
for ((i=0; i<${#syslogconf_files[@]}; i++))
do
	if [ -f ${syslogconf_files[$i]} ]; then
		((file_exists_count++))
		syslogconf_file_owner_name=`ls -l ${syslogconf_files[$i]} | awk '{print $3}'`
		if [[ $syslogconf_file_owner_name =~ root ]] || [[ $syslogconf_file_owner_name =~ bin ]] || [[ $syslogconf_file_owner_name =~ sys ]]; then
			syslogconf_file_permission=`stat ${syslogconf_files[$i]} | grep -i 'Uid' | awk '{print $2}' | awk -F "/" '{print substr($1,3,3)}'`
			if [ $syslogconf_file_permission -le 640 ]; then
				syslogconf_file_owner_permission=`stat ${syslogconf_files[$i]} | grep -i 'Uid' | awk '{print $2}' | awk -F "/" '{print substr($1,3,1)}'`
				if [ $syslogconf_file_owner_permission -eq 6 ] || [ $syslogconf_file_owner_permission -eq 4 ] || [ $syslogconf_file_owner_permission -eq 2 ] || [ $syslogconf_file_owner_permission -eq 0 ]; then
					syslogconf_file_group_permission=`stat ${syslogconf_files[$i]} | grep -i 'Uid' | awk '{print $2}' | awk -F "/" '{print substr($1,4,1)}'`
					if [ $syslogconf_file_group_permission -eq 4 ] || [ $syslogconf_file_group_permission -eq 2 ] || [ $syslogconf_file_group_permission -eq 0 ]; then
						syslogconf_file_other_permission=`stat ${syslogconf_files[$i]} | grep -i 'Uid' | awk '{print $2}' | awk -F "/" '{print substr($1,5,1)}'`
						if [ $syslogconf_file_other_permission -ne 0 ]; then    
                            text_arr+=("${syslogconf_files[$i]} 파일의 다른 사용자(other)에 대한 권한이 취약합니다.")
							res_arr+=(`stat ${syslogconf_files[$i]} | grep -i 'Uid'`)
							 ((flag_count++))  
						fi
					else    
                        text_arr+=("${syslogconf_files[$i]} 파일의 그룹 사용자(group)에 대한 권한이 취약합니다.")
						res_arr+=(`stat ${syslogconf_files[$i]} | grep -i 'Uid'`)
						 ((flag_count++))
					fi
				else    
                    text_arr+=("${syslogconf_files[$i]} 파일의 사용자(owner)에 대한 권한이 취약합니다.")
					res_arr+=(`stat ${syslogconf_files[$i]} | grep -i 'Uid'`)
					 ((flag_count++))
				fi
			else
                text_arr+=("${syslogconf_files[$i]} 파일의 권한이 640보다 큽니다.")
				res_arr+=(`stat ${syslogconf_files[$i]} | grep -i 'Uid'`)
				 ((flag_count++))
			fi
		else
            text_arr+=("${syslogconf_files[$i]} 파일의 소유자(owner)가 root(또는 bin, sys)가 아닙니다.")
			res_arr+=(`stat ${syslogconf_files[$i]} | grep -i 'Uid'`)
			 ((flag_count++))
		fi
	fi
done

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
        echo "syslog.conf 파일의 권한과 소유자가 양호합니다."
		for ((i=0; i<${#syslogconf_files[@]}; i++))
		do
			res_Y_arr=(`stat ${syslogconf_files[$i]} | grep -i 'Uid'`)
		done
        echo "${res_Y_arr[@]}"
    fi
fi