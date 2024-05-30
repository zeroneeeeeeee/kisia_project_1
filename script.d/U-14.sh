#!/bin/bash

flag_count=0
text_arr=()
res_arr=()
res_Y_arr=()
user_homedirectory_path=(`awk -F ":" '$7!="/bin/false" && $7!="/sbin/nologin" && $6!=null {print $6}' /etc/passwd`) 
user_homedirectory_path2=(/home/*) 
user_homedirectory_owner_name=(`awk -F : '$7!="/bin/false" && $7!="/sbin/nologin" && $6!=null {print $1}' /etc/passwd`) 
user_homedirectory_owner_name2=() 

for ((i=0; i<${#user_homedirectory_path2[@]}; i++))
do
	user_homedirectory_owner_name2[${#user_homedirectory_owner_name2[@]}]=`echo ${user_homedirectory_path2[$i]} | awk -F / '{print $3}'` 
done
	
start_files=(".profile" ".cshrc" ".login" ".kshrc" ".bash_profile" ".bashrc" ".bash_login")
for ((i=0; i<${#user_homedirectory_path[@]}; i++))
do
	for ((j=0; j<${#start_files[@]}; j++))
	do
		if [ -f ${user_homedirectory_path[$i]}/${start_files[$j]} ]; then
			user_homedirectory_owner_name2=`ls -l ${user_homedirectory_path[$i]}/${start_files[$j]} | awk '{print $3}'`
			if [[ $user_homedirectory_owner_name2 =~ root ]] || [[ $user_homedirectory_owner_name2 =~ ${user_homedirectory_owner_name[$i]} ]]; then
				user_homedirectory_other_execute_permission=`ls -l ${user_homedirectory_path[$i]}/${start_files[$j]} | awk '{print substr($1,9,1)}'`
				if [[ $user_homedirectory_other_execute_permission =~ w ]]; then                  
                    text_arr+=("${user_homedirectory_path[$i]} 홈 디렉터리 내 ${start_files[$j]} 환경 변수 파일에 다른 사용자(other)의 쓰기(w) 권한이 부여 되어 있습니다.")
					res_arr+=(`ls -l ${user_homedirectory_path[$i]}/${start_files[$j]}`)
					((flag_count++))
				fi
			else                
                text_arr+=("${user_homedirectory_path[$i]} 홈 디렉터리 내 ${start_files[$j]} 환경 변수 파일의 소유자(owner)가 root 또는 해당 계정이 아닙니다.")
				res_arr+=(`ls -l ${user_homedirectory_path[$i]}/${start_files[$j]}`)
				((flag_count++))
			fi
		fi
	done
done

if [ $flag_count -eq 0 ]; then
	echo "Y"
	echo "모든 홈 디렉터리 내 환경 변수 파일의 권한 및 소유자가 양호합니다."
	for ((i=0; i<${#user_homedirectory_path[@]}; i++))
	do
		for ((j=0; j<${#start_files[@]}; j++))
		do
			res_Y_arr+=(`ls -l ${user_homedirectory_path[$i]}/${start_files[$j]} 2>/dev/null`)
		done
	done	
	echo "${res_Y_arr[@]}"
else
	echo "N"
	echo "${text_arr[@]}"
	echo "${res_arr[@]}"
fi