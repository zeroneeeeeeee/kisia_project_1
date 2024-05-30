#!/bin/bash
if [ -f /etc/hosts.deny ]; then
	etc_hostsdeny_allall_comment_check=`grep -E '^#' /etc/hosts.deny | awk '{gsub(" ", "", $0); print}' | grep -i 'all:all' | wc -l`
	if [ $etc_hostsdeny_allall_comment_check -gt 0 ]; then
		echo "N"
        echo "/etc/hosts.deny 파일에 'ALL : ALL' 설정이 주석처리 되어 있습니다."
		echo "`cat /etc/hosts.allow | awk '{gsub(" ", "", $0); print}' | grep -i 'all:all'`"
	fi
	etc_hostsdeny_allall_count=`grep -vE '^#' /etc/hosts.deny | awk '{gsub(" ", "", $0); print}' | grep -i 'all:all' | wc -l`
	if [ $etc_hostsdeny_allall_count -gt 0 ]; then
		if [ -f /etc/hosts.allow ]; then
			etc_hostsallow_allall_count=`grep -vE '^#' /etc/hosts.allow | awk '{gsub(" ", "", $0); print}' | grep -i 'all:all' | wc -l`
			if [ $etc_hostsallow_allall_count -gt 0 ]; then
                echo "N"
                echo "/etc/hosts.allow 파일에 'ALL : ALL' 설정이 있습니다."
				echo "`cat /etc/hosts.allow | awk '{gsub(" ", "", $0); print}' | grep -i 'all:all'`"
			else
                echo "Y"
                echo "/etc/hosts.deny 파일에 'ALL : ALL' 설정이 존재하며, /etc/hosts.allow 파일에 'ALL : ALL' 설정이 존재하지 않습니다."
				echo "`cat /etc/hosts.deny | awk '{gsub(" ", "", $0); print}' | grep -i 'all:all'; cat /etc/hosts.allow | awk '{gsub(" ", "", $0); print}' | grep -i 'all:all'`"
			fi
		else
            echo "Y"
            echo "/etc/hosts.deny 파일에 'ALL : ALL' 설정이 존재하며, /etc/hosts.allow 파일에 'ALL : ALL' 설정이 존재하지 않습니다."
			echo "`cat /etc/hosts.deny | awk '{gsub(" ", "", $0); print}' | grep -i 'all:all'; cat /etc/hosts.allow | awk '{gsub(" ", "", $0); print}' | grep -i 'all:all'`"
		fi
	else
        echo "N"
        echo "/etc/hosts.deny 파일에 'ALL : ALL' 설정이 없습니다."
		echo "`cat /etc/hosts.allow | awk '{gsub(" ", "", $0); print}' | grep -i 'all:all'`"
	fi
else
    echo "N"
    echo "/etc/hosts.deny 파일이 없습니다."
	echo "`ls -l /etc/hosts.deny`"
fi