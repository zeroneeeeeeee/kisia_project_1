#!/bin/sh

##############################
##############################


U_55() {

	if [ -f /etc/hosts.lpd ] #파일이 존재하면 참 
    then
		if [ `ls -alL /etc/hosts.lpd | awk '{print $1}' | grep -perm 600 | wc -l` -eq 1 ] # 권한이 600인지 확인
        then
			if [ `ls -alL /etc/hosts.lpd | awk '{print $3}' | grep -i "root" | wc-l` -eq 1 ] # 파일의 소유자가 root인지 확인 
			then
				echo "Y" 
				echo "파일의 소유자가 root이고 권한이 600인 경우에 양호" 
				ls -alL /etc/hosts.lpd  >>result_3 #/etc/hosts.lpd 파일 출력 
				echo "$(cat result_3)"
			else
				echo "N" 
				echo "파일 소유자가 적절하지 않음"
				ls -alL /etc/hosts.lpd  >>result_3 #/etc/hosts.lpd 파일 출력 
				echo "$(cat result_3)"
			fi
        else
			echo "N" 
	        echo "파일 권한이 적절하지 않음"
			ls -alL /etc/hosts.lpd  >>result_3   #/etc/hosts.lpd 파일 출력 
			echo "$(cat result_3)"
		
		fi

    else
		echo "Y" 
		echo "/etc/hosts.lpd 파일이 존재하지 않습니다 " 
		ls -alL /etc/hosts.lpd  >>result_3   #/etc/hosts.lpd 파일 출력 
		echo "$(cat result_3)"
	fi

	rm -rf result_3
}
U_55
