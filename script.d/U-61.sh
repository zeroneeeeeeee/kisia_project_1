#!/bin/sh

###############################
###############################


U_61() {

	find /etc -name 2>/dev/null "proftpd.conf" > proftpd #2>/dev/null
	find /etc -name 2>/dev/null "vsftpd.conf" > vsftpd   #2>/dev/null
	profile=`cat proftpd`
	vsfile=`cat vsftpd`

    #일반 ftp 서비스 포트 확인 
	if [ `cat /etc/services | awk -F" " '$1=="ftp" {print "(1)/etc/service파일:" $1 " " $2}' | grep "tcp" | wc -l` -gt 0 ]
    then
	   cat /etc/services | awk -F" " '$1=="ftp" {print "(1)/etc/service파일:" $1 " " $2}' | grep "tcp" >> ftp_value
    else
	   echo "(1)/etc/service파일: 포트 설정 X (Default 21번 포트)" >> ftp_value
	fi

    #vsftpd 서비스 포트 확인 
	if [ -s vsftpd ]
    then
	   if [ `cat $vsfile | grep "listen_port" | grep -v "^#" | awk '{print "(3)VsFTP 포트: " $1 "  " $2}' | wc -l` -gt 0 ]
		then
			cat $vsfile | grep "listen_port" | grep -v "^#" | awk '{print "(3)VsFTP 포트: " $1 "  " $2}' >> ftp_value
		else
			echo "(2)VsFTP 포트: 포트 설정 X (Default 21번 포트 사용중)" >> ftp_value
	   fi
    else
	   echo "(2)VsFTP 포트: VsFTP가 설치되어 있지 않습니다." >> ftp_value
	fi

    #proftpd 서비스 포트 확인
	if [ -s proftpd ]
    then
	   if [ `cat $profile | grep "Port" | grep -v "^#" | awk '{print "(2)ProFTP 포트: " $1 "  " $2}' | wc -l` -gt 0 ]
		then
			cat $profile | grep "Port" | grep -v "^#" | awk '{print "(2)ProFTP 포트: " $1 "  " $2}' >> ftp_value
		else 
			echo "(3)ProFTP 포트: 포트 설정 X (/etc/service 파일에 설정된 포트 사용중)" >> ftp_value
	   fi
    else
	   echo "(3)ProFTP 포트: ProFTP가 설치되어 있지 않습니다." >> ftp_value
	fi
	
	
    #ftp 서비스 포트 활성화 여부 확인

    #/etc/services 파일에서 포트 확인

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

	if [ `cat ftpenable | grep "enable" | wc -l` -gt 0 ]
    then
		echo "N" 
    else
		echo "Y" 
	fi

	if [ `cat ftpenable | grep -i "ftp disable" | wc -l` -eq 3 ]
	then
		echo "FTP 서비스 포트가 활성화 되어 있지 않습니다." 
	else 
		echo "FTP 서비스 포트가 활성화 되어 있습니다."
	fi 
    
    echo "$(cat ftp_value)"

	rm -rf proftpd vsftpd ftp_value ftpenable

}

U_61
