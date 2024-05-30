#!/bin/bash

if [[ -f /etc/hosts ]]; then
    etc_hosts_owner_name=`ls -l /etc/hosts | awk '{print $3}'`
    if [[ $etc_hosts_owner_name =~ root ]]; then
        etc_hosts_permission=`stat /etc/hosts | grep -i 'Uid' | awk '{print $2}' | awk -F "/" '{print substr($1,3,3)}'`
        if [[ $etc_hosts_permission -le 600 ]]; then
            etc_hosts_owner_permission=`stat /etc/hosts | grep -i 'Uid' | awk '{print $2}' | awk -F "/" '{print substr($1,3,1)}'`
            if [[ $etc_hosts_owner_permission -eq 0 ]] || [[ $etc_hosts_owner_permission -eq 2 ]] || [[ $etc_host_owner_permission -eq 4 ]] || [[ $etc_host_owner_permission -eq 6 ]]; then
                 etc_hosts_group_permission=`stat /etc/hosts | grep -i 'Uid' | awk '{print $2}' | awk -F "/" '{print substr($1,4,1)}'`
                 if [[ $etc_hosts_group_permission -eq 0 ]]; then
                    etc_hosts_other_permission=`stat /etc/hosts | grep -i 'Uid' | awk '{print $2}' | awk -F "/" '{print substr($1,5,1)}'`
                    if [[ $etc_hosts_other_permission -eq 0 ]]; then
                        echo "Y"
                        echo "/etc/hosts 파일이 존재하며, 권한 및 소유자가 양호합니다."
                        echo "`stat /etc/hosts | grep -i 'Uid'`"
                    else
                        echo "N"
                        echo "/etc/hosts 파일의 다른 사용자(other)에 대한 권한이 취약합니다."
                        echo "`stat /etc/hosts | grep -i 'Uid'`"
                    fi
                else
                    echo "N"
                    echo "/etc/hosts 파일의 그룹 사용자(group)에 대한 권한이 취약합니다."
                    echo "`stat /etc/hosts | grep -i 'Uid'`"
                fi
            else
                echo "N"
                echo "/etc/hosts 파일의 사용자(owner)에 대한 권한이 취약합니다."
                echo "`stat /etc/hosts | grep -i 'Uid'`"
            fi
        else
            echo "N"
            echo "/etc/hosts 파일의 권한이 600보다 큽니다."
            echo "`stat /etc/hosts | grep -i 'Uid'`"
        fi
    else
        echo "N"
        echo "/etc/hosts 파일의 소유자(owner)가 root가 아닙니다."
        echo "`stat /etc/hosts | grep -i 'Uid'`"
    fi
else
	echo "N"
	echo "/etc/hosts 파일이 없습니다."
    echo "`ls -l /etc/hosts`"
fi