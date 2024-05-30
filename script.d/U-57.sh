#!/bin/bash

##############################
##############################


U_57() {

	HOMEDIRS=`cat /etc/passwd |  egrep -v "false|nologin"  | awk -F":" 'length($6) > 0 {print $6}' | sort -u | grep -v "^#" | grep -v "/tmp" | grep -v "uucppublic" | grep -v "var" | grep -v "news" | uniq`

	for dir in $HOMEDIRS
    do
		if [ -d $dir ]      
		then
			ls -dal $dir | grep '\d.........' >> homedir 2>&1   #홈 디렉터리의 권한을 확인
        fi
    done

    HOMEDIRS=`cat /etc/passwd | egrep -v "false|nologin" | awk -F":" 'length($6) > 0 {print $6}' | sort -u | grep -v "^#" | grep -v "/tmp" | grep -v "uucppublic" | grep -v "var" | grep -v "news" | uniq`
	for dir in $HOMEDIRS
    do
		if [ -d $dir ]
        then
			if [ `ls -dal $dir |  awk '{print $1}' | grep "........w." | grep '\d.........'| wc -l` -ge 1 ] #타 사용자의 쓰기 권한 확인 
            then
				echo "BAD" >> home
            else
				echo "GOOD" >> home
			fi
		else
			echo "GOOD" >> home
		fi
    done

    if [ `cat home | grep "BAD" | wc -l` -eq 0 ]
        then
            echo "Y" 
        else
            echo "N" 
        fi


	if [ `cat homedir | grep "........w." | wc -l` -ge 1 ]
	then
        echo "타 사용자 쓰기 권한이 부여되어 있습니다." >> result_2
		cat homedir | grep "........w."  >>result_3
	else
		echo "홈 디렉터리 소유자 및 권한 설정이 양호 합니다."  >> result_2
		cat homedir >> result_3
	fi

	echo "$(cat result_2)"
	echo "$(cat result_3)"

	rm -rf home homedir result_2 result_3

}
U_57
