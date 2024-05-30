#!/bin/bash

flag_count=0
text_arr=()
res_arr=()
res_Y_arr=()
user_homedirectory_path=(/home/*) 
r_command=("rsh" "rlogin" "rexec" "shell" "login" "exec")
if [ -d /etc/xinetd.d ]; then
	for ((i=0; i<${#r_command[@]}; i++))
	do
		if [ -f /etc/xinetd.d/${r_command[$i]} ]; then
			etc_xinetdd_rcommand_disable_count=`grep -vE '^#' /etc/xinetd.d/${r_command[$i]} | grep -i 'disable' | grep -i 'yes' | wc -l`
			if [ $etc_xinetdd_rcommand_disable_count -eq 0 ]; then
				if [ -f /etc/hosts.equiv ]; then
					etc_hostsequiv_owner_name=`ls -l /etc/hosts.equiv | awk '{print $3}'`
					if [[ $etc_hostsequiv_owner_name =~ root ]]; then
						etc_hostsequiv_permission=`stat /etc/hosts.equiv | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,3,3)}'`
						if [ $etc_hostsequiv_permission -le 600 ]; then
							etc_hostsequiv_owner_permission=`stat /etc/hosts.equiv | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,3,1)}'`
							if [ $etc_hostsequiv_owner_permission -eq 6 ] || [ $etc_hostsequiv_owner_permission -eq 4 ] || [ $etc_hostsequiv_owner_permission -eq 2 ] || [ $etc_hostsequiv_owner_permission -eq 0 ]; then
								etc_hostsequiv_group_permission=`stat /etc/hosts.equiv | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,4,1)}'`
								if [ $etc_hostsequiv_group_permission -eq 0 ]; then
										etc_hostsequiv_other_permission=`stat /etc/hosts.equiv | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,5,1)}'`
									if [ $etc_hostsequiv_other_permission -eq 0 ]; then
										etc_hostsequiv_plus_count=`grep -vE '^#' /etc/hosts.equiv | grep '+' | wc -l`
										if [ $etc_hostsequiv_plus_count -gt 0 ]; then 
                                            text_arr+=(r 계열 서비스를 사용하고, /etc/hosts.equiv 파일에 '+' 설정이 있습니다.)
											res_arr+=(`cat /etc/xinetd.d/${r_command[$i]} | grep -i 'disable' | grep -i 'yes'; grep -vE '^#' /etc/hosts.equiv | grep '+'`)
											((flag_count++))
										fi
									else    
                                        text_arr+=("r 계열 서비스를 사용하고, /etc/hosts.equiv 파일의 다른 사용자(other)에 대한 권한이 취약합니다.")
										res_arr+=(`cat /etc/xinetd.d/${r_command[$i]} | grep -i 'disable' | grep -i 'yes'; stat /etc/hosts.equiv | grep -i 'Uid'`)
										((flag_count++))
									fi
								else     
                                    text_arr+=("r 계열 서비스를 사용하고, /etc/hosts.equiv 파일의 그룹 사용자(group)에 대한 권한이 취약합니다.")
									res_arr+=(`cat /etc/xinetd.d/${r_command[$i]} | grep -i 'disable' | grep -i 'yes'; stat /etc/hosts.equiv | grep -i 'Uid'`)
									((flag_count++))
								fi
							else    
                                text_arr+=("r 계열 서비스를 사용하고, /etc/hosts.equiv 파일의 사용자(owner)에 대한 권한이 취약합니다.")
								res_arr+=(`cat /etc/xinetd.d/${r_command[$i]} | grep -i 'disable' | grep -i 'yes'; stat /etc/hosts.equiv | grep -i 'Uid'`)
								((flag_count++))
							fi
						else    
                            text_arr+=(r 계열 서비스를 사용하고, /etc/hosts.equiv 파일의 권한이 600보다 큽니다.)
							res_arr+=(`cat /etc/xinetd.d/${r_command[$i]} | grep -i 'disable' | grep -i 'yes'; stat /etc/hosts.equiv | grep -i 'Uid'`)
							((flag_count++))
						fi
					else          
                        text_arr+=("r 계열 서비스를 사용하고, /etc/hosts.equiv 파일의 소유자(owner)가 root가 아닙니다.")
						res_arr+=(`cat /etc/xinetd.d/${r_command[$i]} | grep -i 'disable' | grep -i 'yes'; stat /etc/hosts.equiv | grep -i 'Uid'`)
						((flag_count++))
					fi
				fi
				for ((j=0; j<${#user_homedirectory_path[@]}; j++))
				do
					if [ -f ${user_homedirectory_path[$j]}/.rhosts ]; then
						user_homedirectory_rhosts_owner_name=`ls -l ${user_homedirectory_path[$j]}/.rhosts | awk '{print $3}'`
						if [[ $user_homedirectory_rhosts_owner_name =~ root ]] || [[ $user_homedirectory_rhosts_owner_name =~ ${user_homedirectory_owner_name[$j]} ]]; then
							user_homedirectory_rhosts_permission=`stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,3,3)}'`
							if [ $user_homedirectory_rhosts_permission -le 600 ]; then
								user_homedirectory_rhosts_owner_permission=`stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,3,1)}'`
								if [ $user_homedirectory_rhosts_owner_permission -eq 6 ] || [ $user_homedirectory_rhosts_owner_permission -eq 4 ] || [ $user_homedirectory_rhosts_owner_permission -eq 2 ] || [ $user_homedirectory_rhosts_owner_permission -eq 0 ]; then
									user_homedirectory_rhosts_group_permission=`stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,4,1)}'`
									if [ $user_homedirectory_rhosts_group_permission -eq 0 ]; then
										user_homedirectory_rhosts_other_permission=`stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,5,1)}'`
										if [ $user_homedirectory_rhosts_other_permission -eq 0 ]; then
											user_homedirectory_rhosts_plus_count=`grep -vE '^#' ${user_homedirectory_path[$j]}/.rhosts | grep '+' | wc -l`
											if [ $user_homedirectory_rhosts_plus_count -gt 0 ]; then                                          
                                                text_arr+=(r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일에 '+' 설정이 있습니다.)
												res_arr+=(`cat /etc/xinetd.d/${r_command[$i]} | grep -i 'disable' | grep -i 'yes'; grep -vE '^#' ${user_homedirectory_path[$j]}/.rhosts | grep '+'`)
												((flag_count++))
											fi
										else                                          
                                            text_arr+=("r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일의 다른 사용자(other)에 대한 권한이 취약합니다.")
											res_arr+=(`cat /etc/xinetd.d/${r_command[$i]} | grep -i 'disable' | grep -i 'yes'; stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid'`)
											((flag_count++))
										fi
									else      
                                        text_arr+=("r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일의 그룹 사용자(group)에 대한 권한이 취약합니다.")
										res_arr+=(`cat /etc/xinetd.d/${r_command[$i]} | grep -i 'disable' | grep -i 'yes'; stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid'`)
										((flag_count++))
									fi
							    else            
                                    text_arr+=("r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일의 사용자(owner)에 대한 권한이 취약합니다.")
									res_arr+=(`cat /etc/xinetd.d/${r_command[$i]} | grep -i 'disable' | grep -i 'yes'; stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid'`)
									((flag_count++))
								fi
							else                              
                                text_arr+=("r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일의 권한이 600보다 큽니다.")
								res_arr+=(`cat /etc/xinetd.d/${r_command[$i]} | grep -i 'disable' | grep -i 'yes'; stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid'`)
								((flag_count++))
							fi
						else                           
                            text_arr+=("r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일의 소유자(owner)가 root 또는 해당 계정이 아닙니다.")
							res_arr+=(`cat /etc/xinetd.d/${r_command[$i]} | grep -i 'disable' | grep -i 'yes'; stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid'`)
							((flag_count++))
						fi
					fi
				done
			fi
		fi
	done
fi
if [ -f /etc/inetd.conf ]; then
	for ((i=0; i<${#r_command[@]}; i++))
	do
		if [ `grep -vE '^#' /etc/inetd.conf | grep  ${r_command[$i]} | wc -l` -gt 0 ]; then
			if [ -f /etc/hosts.equiv ]; then
				etc_hostsequiv_owner_name=`ls -l /etc/hosts.equiv | awk '{print $3}'`
				if [[ $etc_hostsequiv_owner_name =~ root ]]; then
					etc_hostsequiv_permission=`stat /etc/hosts.equiv | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,3,3)}'`
					if [ $etc_hostsequiv_permission -le 600 ]; then
						etc_hostsequiv_owner_permission=`stat /etc/hosts.equiv | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,3,1)}'`
						if [ $etc_hostsequiv_owner_permission -eq 6 ] || [ $etc_hostsequiv_owner_permission -eq 4 ] || [ $etc_hostsequiv_owner_permission -eq 2 ] || [ $etc_hostsequiv_owner_permission -eq 0 ]; then
							etc_hostsequiv_group_permission=`stat /etc/hosts.equiv | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,4,1)}'`
							if [ $etc_hostsequiv_group_permission -eq 0 ]; then
								etc_hostsequiv_other_permission=`stat /etc/hosts.equiv | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,5,1)}'`
								if [ $etc_hostsequiv_other_permission -eq 0 ]; then
									etc_hostsequiv_plus_count=`grep -vE '^#' /etc/hosts.equiv | grep '+' | wc -l`
									if [ $etc_hostsequiv_plus_count -gt 0 ]; then                                       
                                        text_arr+=(r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일에 '+' 설정이 있습니다.)
										res_arr+=(`cat /etc/inetd.conf | grep  ${r_command[$i]}; grep -vE '^#' /etc/hosts.equiv | grep '+'`)
										((flag_count++))
									fi
								else                                   
                                    text_arr+=("r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일의 다른 사용자(other)에 대한 권한이 취약합니다.")
									res_arr+=(`cat /etc/inetd.conf | grep  ${r_command[$i]}; stat /etc/hosts.equiv | grep -i 'Uid'`)
									((flag_count++))
								fi
							else                              
                                text_arr+=("r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일의 그룹 사용자(group)에 대한 권한이 취약합니다.")
								res_arr+=(`cat /etc/inetd.conf | grep  ${r_command[$i]}; stat /etc/hosts.equiv | grep -i 'Uid'`)
								((flag_count++))
							fi
						else
                            text_arr+=("r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일의 사용자(owner)에 대한 권한이 취약합니다.")
							res_arr+=(`cat /etc/inetd.conf | grep  ${r_command[$i]}; stat /etc/hosts.equiv | grep -i 'Uid'`)
							((flag_count++))
						fi
					else
                        text_arr+=("r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일의 권한이 600보다 큽니다.")
						res_arr+=(`cat /etc/inetd.conf | grep  ${r_command[$i]}; stat /etc/hosts.equiv | grep -i 'Uid'`)
						((flag_count++))
					fi
				else
                    text_arr+=("r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일의 소유자(owner)가 root 또는 해당 계정이 아닙니다.")
					res_arr+=(`cat /etc/inetd.conf | grep  ${r_command[$i]}; stat /etc/hosts.equiv | grep -i 'Uid'`)
					((flag_count++))
				fi
			fi
			for ((j=0; j<${#user_homedirectory_path[@]}; j++))
            do
				if [ -f ${user_homedirectory_path[$j]}/.rhosts ]; then
					user_homedirectory_rhosts_owner_name=`ls -l ${user_homedirectory_path[$j]}/.rhosts | awk '{print $3}'`
					if [[ $user_homedirectory_rhosts_owner_name =~ root ]] || [[ $user_homedirectory_rhosts_owner_name =~ ${user_homedirectory_owner_name[$j]} ]]; then
						user_homedirectory_rhosts_permission=`stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,3,3)}'`
						if [ $user_homedirectory_rhosts_permission -le 600 ]; then
							user_homedirectory_rhosts_owner_permission=`stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,3,1)}'`
							if [ $user_homedirectory_rhosts_owner_permission -eq 6 ] || [ $user_homedirectory_rhosts_owner_permission -eq 4 ] || [ $user_homedirectory_rhosts_owner_permission -eq 2 ] || [ $user_homedirectory_rhosts_owner_permission -eq 0 ]; then
								user_homedirectory_rhosts_group_permission=`stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,4,1)}'`
								if [ $user_homedirectory_rhosts_group_permission -eq 0 ]; then
									user_homedirectory_rhosts_other_permission=`stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,5,1)}'`
									if [ $user_homedirectory_rhosts_other_permission -eq 0 ]; then
										user_homedirectory_rhosts_plus_count=`grep -vE '^#' ${user_homedirectory_path[$j]}/.rhosts | grep '+' | wc -l`
										if [ $user_homedirectory_rhosts_plus_count -gt 0 ]; then
                                            text_arr+=(r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일에 '+' 설정이 있습니다.)
											res_arr+=(`cat /etc/inetd.conf | grep  ${r_command[$i]}; grep -vE '^#' ${user_homedirectory_path[$j]}/.rhosts | grep '+'`)
											((flag_count++))
										fi
									else
                                        text_arr+=("r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일의 다른 사용자(other)에 대한 권한이 취약합니다.")
										res_arr+=(`cat /etc/inetd.conf | grep  ${r_command[$i]}; stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid'`)
										((flag_count++))
									fi
								else
                                    text_arr+=("r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일의 그룹 사용자(group)에 대한 권한이 취약합니다.")
									res_arr+=(`cat /etc/inetd.conf | grep  ${r_command[$i]}; stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid'`)
									((flag_count++))
								fi
							else
                                text_arr+=("r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일의 사용자(owner)에 대한 권한이 취약합니다.")
								res_arr+=(`cat /etc/inetd.conf | grep  ${r_command[$i]}; stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid'`)
								((flag_count++))
							fi
						else
                            text_arr+=("r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일의 권한이 600보다 큽니다.")
							res_arr+=(`cat /etc/inetd.conf | grep  ${r_command[$i]}; stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid'`)
							((flag_count++))
						fi
					else                       
                        text_arr+=("r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일의 소유자(owner)가 root 또는 해당 계정이 아닙니다.")
						res_arr+=(`cat /etc/inetd.conf | grep  ${r_command[$i]}; stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid'`)
						((flag_count++))
					fi
				fi
			done
		fi
	done
fi

if [ $flag_count -eq 0 ]; then
	echo "Y"
	echo "r 계열 서비스를 사용하지 않고, /etc/hosts.equiv 파일 및 .rhost의 권한 및 소유자가 양호합니다."
	if [ -d /etc/xinetd.d ]; then
		for ((i=0; i<${#r_command[@]}; i++))
		do
			if [ -f /etc/xinetd.d/${r_command[$i]} ]; then
				res_Y_arr+=(`cat /etc/xinetd.d/${r_command[$i]} | grep -i 'disable' | grep -i 'yes' 2>/dev/null`)
			fi
		done
	fi

	if [ -f /etc/inetd.conf ]; then
		for ((i=0; i<${#r_command[@]}; i++))
		do
			res_Y_arr+=(`cat /etc/inetd.conf | grep  ${r_command[$i]} 2>/dev/null`)
		done
	fi

	if [ -f /etc/hosts.equiv ]; then
		res_Y_arr+=(`stat /etc/hosts.equiv | grep -i 'Uid' 2>/dev/null`)
	fi

	for ((j=0; j<${#user_homedirectory_path[@]}; j++))
	do
		if [ -f ${user_homedirectory_path[$j]}/.rhosts ]; then
			res_Y_arr+=(`stat ${user_homedirectory_path[$j]}/.rhosts | grep -i 'Uid'`)
		fi
	done
	echo "${res_Y_arr[@]}"
else
	echo "N "
    echo "${text_arr[@]}"
    echo "${res_arr[@]}"
fi