#!/bin/sh

###########################
###########################


U_58() {
    
    # /etc/passwd 파일을 읽어 각 행에서 사용자의 홈 디렉터리를 확인하고, 홈 디렉터리가 존재하지 않는 경우 HOMEDIRS에 추가 
	HOMEDIRS=$(awk -F: '$6 ~ /^$/ {print $1, $6}' /etc/passwd) 

	if [ -z "$HOMEDIRS" ]; then   #파일이 존재하지 않으면 참 
		echo "홈 디렉터리가 존재하지 않은 계정이 발견되지 않았습니다." > text
	else
		echo "홈 디렉터리가 존재하지 않은 계정이 발견되었습니다." > text
    fi

	# 결과를 확인하여 양호 또는 취약을 결정
	if [ -z "$HOMEDIRS" ]; then
		echo "Y" 
        cat text
	else
		echo "N" 
        cat text
	fi

    echo "$HOMEDIRS"  #홈 디렉터리가 존재하지 않은 계정을 출력 
    
    rm -rf text Home
}
 
U_58
