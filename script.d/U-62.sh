#!/bin/sh

######################
######################



U_62() {

	#ftp 계정 쉘 확인(ftp 계정에 false 설정시 양호)

    #ftp 사용자를 찾고 그 사용자의 쉘이 /bin/false 인지 확인 
	if [ `cat /etc/passwd | awk -F: '$1=="ftp"' | egrep "/bin/false" | wc -l` -gt 0 ]
	then
		result62='good'  #/bin/false 쉘 부여 O
    else
		result62='Bad'   #/bin/false 쉘 부여 X
	fi   

	#ftp 사용자를 찾음
	if [ `cat /etc/passwd | awk -F: '$1=="ftp"' | wc -l` -gt 0 ]
    then
       echo "/etc/passwd 파일에서 ftp 사용자가 있습니다." >> result
    else
	   echo "ftp 계정이 존재하지 않습니다." >> result
	   result62='good'
	fi

	if [ $result62 = 'good' ]
	then
		result62='Y'
	else
		result62='N'
	fi
	
	echo $result62 
    echo "$(cat result)"
    echo "$(cat /etc/passwd | awk -F: '$1=="ftp"')"

    rm -rf result


}
U_62