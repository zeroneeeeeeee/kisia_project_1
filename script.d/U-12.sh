#!/bin/bash
res_arr=()
if [ -f /etc/services ]; then
	etc_services_owner_name=`ls -l /etc/services | awk '{print $3}'`
	if [[ $etc_services_owner_name =~ root ]] || [[ $etc_services_owner_name =~ bin ]] || [[ $etc_services_owner_name =~ sys ]]; then
		etc_services_permission=`stat /etc/services | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,3,3)}'`
		if [ $etc_services_permission -le 644 ]; then
			etc_services_owner_permission=`stat /etc/services | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,3,1)}'`
			if [ $etc_services_owner_permission -eq 6 ] || [ $etc_services_owner_permission -eq 4 ] || [ $etc_services_owner_permission -eq 2 ] || [ $etc_services_owner_permission -eq 0 ]; then
				etc_services_group_permission=`stat /etc/services | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,4,1)}'`
				if [ $etc_services_group_permission -eq 4 ] || [ $etc_services_group_permission -eq 0 ]; then
					etc_services_other_permission=`stat /etc/services | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,5,1)}'`
					if [ $etc_services_other_permission -eq 4 ] || [ $etc_services_other_permission -eq 0 ]; then
	                    echo "Y"
                        echo "/etc/services 파일이 존재하며, 권한 및 소유자가 양호합니다."
						res_arr+=(`stat /etc/services | grep -i 'Uid'`)
						echo "${res_arr[@]}"
					else
                        echo "N"
                        echo "/etc/services 파일의 다른 사용자(other)에 대한 권한이 취약합니다."
						echo "`stat /etc/services | grep -i 'Uid'`"
					fi
				else
                    echo "N"
                    echo "/etc/services 파일의 그룹 사용자(group)에 대한 권한이 취약합니다."
					echo "`stat /etc/services | grep -i 'Uid'`"
				fi
			else
                echo "N"
                echo "/etc/services 파일의 사용자(owner)에 대한 권한이 취약합니다."
				echo "`stat /etc/services | grep -i 'Uid'`"
			fi
		else
            echo "N"
            echo "/etc/services 파일의 권한이 644보다 큽니다."
			echo "`stat /etc/services | grep -i 'Uid'`"
		fi
	else
        echo "N"
        echo "/etc/services 파일의 파일의 소유자(owner)가 root(또는 bin, sys)가 아닙니다."
		echo "`stat /etc/services | grep -i 'Uid'`"
	fi
else
	echo "N"
	echo "/etc/services 파일이 없습니다."
	echo "`ls -l /etc/services`"
fi