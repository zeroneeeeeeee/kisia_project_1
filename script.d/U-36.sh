#!/bin/bash

# Apache 웹 서버의 설정 파일을 확인할 목록
webconf_files=(".htaccess" "httpd.conf" "apache2.conf")
#webconf_files=("apache2.conf")

flag=0
flag1=0

# 주어진 설정 파일 목록을 반복하여 확인합니다.
for webconf_file in "${webconf_files[@]}"; do
    # 주어진 이름의 웹 서버 설정 파일이 존재하는지 확인합니다.
    find_webconf_file_count=$(find / -name "$webconf_file" -type f 2>/dev/null | wc -l)
    if [ "$find_webconf_file_count" -gt 0 ]; then
        # 설정 파일이 존재하는 경우 해당 파일들을 배열로 저장합니다.
        find_webconf_files=($(find / -name "$webconf_file" -type f 2>/dev/null))
        # 각 설정 파일에 대해 확인합니다.
        for find_webconf_file in "${find_webconf_files[@]}"; do
            # 설정 파일에서 Group 설정을 확인합니다.
            webconf_file_group=$(grep -vE '^#|^\s#' "$find_webconf_file" | grep '^\s*Group' | awk '{print $2}' | sed 's/[{}]\+//g')
            # Group 설정이 root인 경우를 확인합니다.

            # locate root group in /etc/apache2/envvars
            if [ -n "$webconf_file_group" ] && [[ "$webconf_file_group" == "\$APACHE_RUN_GROUP" ]]; then
                if [[ $(grep 'APACHE_RUN_GROUP' /etc/apache2/envvars | awk -F'=' '{print $2}') == "root" ]]; then
                    flag=1
                    flag1=1
                fi
            fi
            # locate root user in /etc/apache2/envvars
            if [ -n "$webconf_file_group" ] && [[ "$webconf_file_group" == "\$APACHE_RUN_USER" ]]; then
                if [[ $(grep 'APACHE_RUN_USER' /etc/apache2/envvars | awk -F'=' '{print $2}') == "root" ]]; then
                    flag=1
                    flag1=1
                fi
            fi 
            if [ -n "$webconf_file_group" ] && [[ "$webconf_file_group" == *"root"* ]]; then
                # root 그룹으로 설정된 경우 취약점으로 판단하고 메시지를 출력합니다.
                vls=$find_webconf_file
                flag=1
            fi
        done
    fi
done

#exit 0

if [ $flag -eq 1 ]; then
    if [ $flag1 -eq 1 ]; then
        echo "N"
        echo "Apache 데몬이 root 권한으로 구동중"
        r=$(cat /etc/apache2/envvars)
        echo "$r"
    else
        echo "N"
        echo "Apache 데몬이 root 권한으로 구동중"
        r=$(grep -vE '^#|^\s#' "$vls" | grep '^\s*Group')
        echo "$r"
    fi
else
    echo "Y"
    echo "U-36 : Apache 데몬이 root 권한으로 구동중이지 않거나, Apache 데몬이 존재하지 않습니다."
    r=$(ps -ef | grep 'apache')
    echo "$r"
fi