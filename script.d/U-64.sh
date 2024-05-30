#!/bin/sh

#################################
#################################


U_64() {

    ftp_port=$(awk -F" " '$1=="ftp" {print $2}' /etc/services 2>/dev/null)
	
	if [ -n "$ftp_port" ]; then
	 
	   if [ `ss -nat | grep ":$ftp_port " | grep -qi "^tcp.*LISTEN" | wc -l` -gt 0 ]
		then
			ss -nat | grep ":$ftp_port " | grep -i "^tcp" | grep -i "LISTEN" 
			echo "ftp enable" > ftpenable
		else
			ss -nat | grep ":21 " | grep -i "^tcp" | grep -i "LISTEN" 
			echo "ftp disable" > ftpenable
	   fi
   else
	   echo "ftp disable" >ftpenable
	fi

    #vsftpd 서비스 포트 활성화 여부 확인
	if [ -s vsftpd ]
    then
	   if [ `cat $vsfile | grep "listen_port" | grep -v "^#" | awk -F"=" '{print $2}' | wc -l` -eq 0 ]
		then
			port=21
		else
			port=`cat $vsfile | grep "listen_port" | grep -v "^#" | awk -F"=" '{print $2}'`
	   fi
	   if [ `ss -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]
		then
			ss -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" 
			echo "ftp enable" >> ftpenable
	   fi
	else
		echo "ftp disable" >> ftpenable
	fi

	#proftpd 서비스 포트 활성화 여부 확인
	if [ -s proftpd ]
    then
		port=`cat $profile | grep "Port" | grep -v "^#" | awk '{print $2}'`

	   if [ `ss -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]
		then
			ss -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" 
			echo "ftp enable"  >> ftpenable
		else
			echo "ftp disable" >> ftpenable
	   fi
	else
	   echo "ftp disable" >> ftpenable
	fi

################################################ftpenable #######################################################


	#/etc/ftpd/ftpusers 파일 설정 값
	
	if [ -f ftpenable ]
	then
		if [ `cat ftpenable | grep "enable" | wc -l` -gt 0 ]
		then
			if [ -f /etc/ftpd/ftpusers ]
			then
				cat /etc/ftpd/ftpusers >>result_3
				
			else
				echo "/etc/ftpd/ftpusers  파일이 존재하지 않습니다." >>result_3
				
			fi
		fi
		
		find /etc -name 2>/dev/null "vsftpd.conf" > vsftpd
		
		if [ -s vsftpd ]
		then
    			#vsftpd.conf 파일 설정 값
    			cat vsftpd >>result_3
    			
		else
    			echo "vsftpd.conf 파일이 존재하지 않습니다." >>result_3
    			
		fi



		if [ -f /etc/ftpusers ]
        then
			#/etc/ftpuser 파일 설정 값
			cat /etc/ftpusers >>result_3
			
		else
			if [ -f /etc/vsftpd/ftpusers ]
			then
				#/etc/vsftpd/ftpuser 파일 설정 값
				cat /etc/vsftpd/ftpusers >>result_3
				
			else
				echo "/etc/ftpusers 및 /etc/vsftpd/ftpusers 파일이 존재하지 않습니다." >>result_3
				
			fi
		fi

		if [ -f /etc/vsftpd/user_list ]
        then
			#/etc/vsftpd/user_list 파일 설정 값
			cat /etc/vsftpd/user_list >>result_3
			
        else
			echo "/etc/vsftpd/user_list 파일이 존재하지 않습니다. " >>result_3
			
		fi
	else
		echo "ftp 비활성화되어 있습니다." >>result_3
	fi
	
	

	FILES="/etc/ftpusers /etc/ftpd/ftpusers /etc/vsftpd/ftpusers /etc/vsftpd/user_list"

	for check_file in $FILES
	do
		if [ -f $check_file ]
	   then
			cat $check_file 2>/dev/null | grep -i root | grep -v "^#" >> ftp
		fi
	done
	

	if [ -f ftpenable ]
	then
		if [ `cat ftpenable | grep "enable" | wc -l` -gt 0 ]
		then
			echo "FTP 서비스가 활성화 되어있습니다." >> result_2
			
			if [ `cat ftp | grep root | wc -l` -eq 0 ]
			then
				echo "N"
			else
				echo "Y"
			fi
		else
			echo "FTP 서비스가 비활성화 되어있습니다." >> result_2
			
			echo "Y"
		fi
	fi

    echo "$(cat result_2)"
    echo "$(cat result_3)"


	rm -rf ftpenable ftp vsftpd result_2 result_3

}

U_64
