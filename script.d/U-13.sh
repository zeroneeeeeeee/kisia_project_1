#!/bin/bash

flag_count=0
text_arr=()
res_arr=()
excutables=(`find /usr -xdev -user root -type f -perm 4000 -o -perm 2000 | grep "bin"`)
for ((i=0; i<${#excutables[$i]}; i++))
do
    if [-f ${excutables[$i]} ]; then
        if [ `ls -l ${executables[$i]} | awk '{print substr($1,2,9)}' | grep -i 's' | wc -l` -gt 0 ]; then
            text_arr+=(주요 실행 파일의 권한에 SUID나 SGID에 대한 설정이 부여되어 있습니다.)
            res_arr+=(`ls -l ${executables[$i]}`)
            ((flag_count++))
        fi
    fi
done

if [ $flag_count -eq 0 ]; then
    echo "Y"
    echo "주요 실행 파일의 권한 설정이 양호합니다."
    echo "`find /usr -xdev -user root -type f -perm 4000 -o -perm 2000 | grep "bin"`"
else
    echo "N"
    echo "${text_arr[@]}"
    echo "${res_arr[@]}"
fi