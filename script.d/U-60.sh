#!/bin/sh

##############################
##############################



U_60() {

    #프로세스 데몬 동작 확인
	#if [ `ps -ef | grep sshd | grep -v "grep" | wc -l` -eq 0 ]
	#then
	#	echo "SSH 서비스 비활성화되어 있습니다." >>result_2
	#else
    #    # echo "SSH 서비스 활성화되어 있습니다." >>result_2
	#	ps -ef | grep sshd | grep -v "grep" 
	#fi
	

	#서비스 포트 확인
	ServiceDIR="/etc/sshd_config /etc/ssh/sshd_config /usr/local/etc/sshd_config /usr/local/sshd/etc/sshd_config /usr/local/ssh/etc/sshd_config"

	for file in $ServiceDIR
    do
	   if [ -f $file ]
		then
			if [ `cat $file | grep "^Port" | grep -v "^#" | wc -l` -gt 0 ] #파일에서 포트 설정이 있는지 확인 
			then
                #포트 설정이 있으면 해당 파일과 설정을 추가
				cat $file | grep "^Port" | grep -v "^#" | awk '{print "SSH 설정파일('${file}'): " $0 }' >> ssh-result
                #포트 번호를 추가
				port1=`cat $file | grep "^Port" | grep -v "^#" | awk '{print $2}'`
				echo $port1 >> port1-search
			else
                #포트 설정이 없으면 기본값이 22포트를 사용하는 메시지를 추가 
				printf "SSH 설정파일(%s): 포트 설정 X (Default 설정: 22포트 사용)\n" "$file" >> ssh-result 
			fi
	   fi
    done
	
	if [ `cat ssh-result | grep -v "^ *$" | wc -l` -gt 0 ] # 공백으로만 이루어진 라인을 제외하고 출력 
    then
	   cat ssh-result | grep -v "^ *$" >> result_3
    else
	   echo "SSH 설정파일: 설정 파일을 찾을 수 없습니다." >> result_2
	fi
	

	# 서비스 포트 점검

	#ssh port 확인
	if [ -f port1-search ]
    then
	   if [ `ss -nat | grep ":$port1 " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -eq 0 ]
		then
			echo "SSH 서비스 비활성화되어 있습니다." >>result_2
		else
            echo "SSH 서비스 활성화되어 있습니다." >>result_2
			ss -na | grep ":$port1 " | grep -i "^tcp" | grep -i "LISTEN" >> result_3
	   fi
    else
	   if [ `ss -nat | grep ":22 " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -eq 0 ]
		then
			echo "SSH 서비스 비활성화되어 있습니다." >>result_2
		else
            echo "SSH 서비스 활성화되어 있습니다." >>result_2
			ss -nat | grep ":22 " | grep -i "^tcp" | grep -i "LISTEN" >>result_3
	   fi
	fi


	#telnet port 확인
	if [ `ss -na | grep -i ":23 " | wc -l` -gt 0 ]
	then
		ss -na | grep ":23 "
		active_telnet="false"
        echo "Telnet 서비스 활성화되어 있습니다." >>result_2
	else
		active_telnet="true"
		echo "Telnet 서비스 비활성화되어 있습니다." >>result_2
	fi
	
	if [ $active_telnet = "true" ]
	then
		if [ -f port1-search ]
		then
			if [ `ss -nat | grep ":$port1 " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -eq 0 ]
			then
				echo "Y"
			else
				echo "N" 
			fi
		else
			if [ `ss -nat | grep ":22 " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -eq 0 ]
			then
				echo "Y" 
			else
				echo "N"
			fi
		fi
	else
		#echo "Telnet 서비스가 활성화 되어있음" >>result_2
		echo "N" 
	fi

    echo "$(cat result_2)"
    echo "$(cat result_3)"
	

	rm -rf ssh-result port1-search result_2 result_3 

}

U_60
