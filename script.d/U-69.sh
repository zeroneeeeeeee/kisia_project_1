#!/bin/sh

###########################
###########################


U_69() {

	if [ -f  /etc/exports ]
    then
		.
    else
		echo "/etc/exports 파일이 존재하지 않습니다." >>result_2
	fi
	

	if [ -f /etc/exports ]
    then
		if [ `ls -alL /etc/exports | awk '{print $1}' | grep '644' | wc -l` -eq 1 ]
        then
			if [ `ls -alL /etc/exports | awk '{print $3}' | grep -i "root" | wc -l` -eq 1 ]
			then
                echo "NFS 접근제어 설정 파일의 소유자가 root이고, 권한이 644 이하 입니다." >>result_2
				echo "Y" 
			else
				echo "NFS 접근제어 설정 파일의 파일 소유자가 적절하지 않습니다." >>result_2
				echo "N" 
			fi
        else
			echo "NFS 접근제어 설정 파일의 파일 권한이 적절하지 않습니다." >>result_2
			echo "N" 
		fi
    else
		echo "Y" 
	fi

    echo "$(cat result_2)"
    ls -alL /etc/exports

    rm -rf result_2 
}
U_69
