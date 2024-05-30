#!/bin/bash

########################
########################


U_68() {

    touch ssh-banner
    
	# 파일 목록 배열 정의
	files=(/etc/issue.net /etc/issue /etc/motd /etc/ssh/sshd_config /etc/xinetd.d/* /etc/mail/sendmail.cf /etc/named.conf)

	# 각 파일에 대한 처리
	for file in "${files[@]}"; do
		echo "$file check" >> result_3
		echo "--------------------------------------------" >>result_3
		if [ -f "$file" ]; then
			cat "$file" >>result_3
			if [ $(cat "$file" | wc -l) -gt 0 ]; then
				echo "GOOD" >> banner
			else
				echo "BAD" >> banner
			fi
		else
			echo "$file not found." >>result_3
			echo "BAD" >> banner
		fi
		echo " " >>result_3
	done

	# SSH 관련 설정
	echo "1. SSH 관련 설정" >>result_2
	if ps -ef | grep sshd | grep -qv "grep"; then
		echo " SSH 서비스 활성화되어 있습니다." >>result_2		 
		#cat ssh-banner >> result_3

		#연동된 ssh 배너파일 존재시 해당 파일 내용 
		if [ $(grep -v "^#" ssh-banner | wc -l) -gt 0 ]; then
			ssh_path=$(awk '/banner/ {print $4}' ssh-banner)
			echo " ssh 배너 연동이 적절합니다." >>result_2
			echo "GOOD" >> banner
		else
			echo " ssh 배너 연동이 적절하지 않습니다." >>result_2
			echo "BAD" >> banner
		fi
		#cat "$ssh_path" >>result_3
	else
		echo " SSH 서비스 비활성화되어 있습니다." >>result_2
	fi

	# Telnet 서비스 확인
	echo "2. Telnet 서비스 확인" >>result_2
	if ps -ef | grep telnetd | grep -qv "grep" || grep -q telnetd /etc/telnetd; then
		echo " Telnet 서비스 활성화되어 있습니다." >>result_2
		#cat /etc/issue >> telnetbanner
		#cat /etc/issue.net >> telnetbanner
		
		if grep -q -vE "Linux|Kernel" telnetbanner; then
			echo "GOOD" >> banner
			#ls -al /etc/issue >>result_3
			#ls -al /etc/issue.net  >>result_3
			
		else
			echo "BAD" >> banner
			#ls -al /etc/issue >>result_3
			#ls -al /etc/issue.net >>result_3
			
		fi 
	else
		echo " Telnet 서비스 비활성화되어 있습니다." >>result_2
		echo "GOOD" >> banner
	fi

	# FTP 서비스 확인
	echo "3. FTP 서비스 확인" >>result_2
	if ps -ef | grep ftp | grep -qv "grep" || grep -q -v tftp /etc/default/ftpd; then
		echo " FTP 서비스 활성화되어 있습니다." >>result_2
		# FTP 배너 설정 여부 확인

		# 파일 경로 및 설정 여부에 따른 처리
		if [ -f /etc/welcome.msg ]; then
			# /etc/welcome.msg 파일이 존재하는 경우
			if grep -q -i "banner" /etc/welcome.msg && grep -q "=" /etc/welcome.msg && grep -q "\".\"" /etc/welcome.msg; then
				echo " /etc/welcome.msg 파일이 존재합니다." >>result_2
				echo "GOOD" >> banner
				#cat /etc/welcome.msg  >>result_3
			else
				echo " /etc/welcome.msg 파일이 존재하지 않습니다." >>result_2
				echo "BAD" >> banner
				#cat /etc/welcome.msg  >>result_3
			fi
		elif [ -f /etc/vsftpd.conf ]; then
			# vsftpd 설정 파일이 존재하는 경우
			if grep -q -i "ftp_banner" /etc/vsftpd.conf && grep -q "=" /etc/vsftpd.conf; then
				echo " vsftpd 설정 파일이 존재합니다." >>result_2
				echo "GOOD" >> banner
				#cat /etc/vsftpd.conf | grep -i "ftp_banner"  >>result_3
			else
				echo " vsftpd 설정 파일이 존재하지 않습니다.">>result_2
				echo "BAD" >> banner
				#cat /etc/vsftpd.conf | grep -i "ftp_banner"  >>result_3
			fi
		elif [ -f /etc/proftpd.conf ]; then
			# proftpd 설정 파일이 존재하는 경우
			if grep -q -i "Serverldent" /etc/proftpd.conf && grep -q -i "off" /etc/proftpd.conf; then
				echo " proftpd 설정 파일이 존재합니다.">>result_2
				echo "GOOD" >> banner
			else
				echo " proftpd 설정 파일이 존재하지 않습니다.">>result_2
				echo "BAD" >> banner
				#cat /etc/proftpd.conf | grep -i "Serverldent" >>result_3
			fi
		elif [ -f /usr/local/etc/proftpd.conf ]; then
			# /usr/local/etc/proftpd.conf 파일이 존재하는 경우
			if grep -q -i "Serverldent" /usr/local/etc/proftpd.conf && grep -q -i "off" /usr/local/etc/proftpd.conf; then
				echo " /usr/local/etc/proftpd.conf 파일이 존재합니다.">>result_2
				echo "GOOD" >> banner
			else
				echo " /usr/local/etc/proftpd.conf 파일이 존재하지 않습니다.">>result_2
				echo "BAD" >> banner
				#cat /usr/local/etc/proftpd.conf | grep -i "Serverldent" >>result_3
			fi
		elif [ -f /etc/ftpaccess ]; then
			# /etc/ftpaccess 파일이 존재하는 경우
			if grep -q -i "greeting" /etc/ftpaccess && grep -q -i "terse" /etc/ftpaccess; then
				echo " /etc/ftpaccess 파일이 존재합니다.">>result_2
				echo "GOOD" >> banner
			else
				echo " /etc/ftpaccess 파일이 존재하지 않습니다.">>result_2
				echo "BAD" >> banner
				#cat /etc/ftpaccess | grep -i "greeting" | grep -i "terse" >>result_3
			fi
		else
			echo "미점검" >> banner
		fi
	else
		echo " FTP 서비스 비활성화되어 있습니다." >>result_2
		echo "GOOD" >> banner
	fi

	# SMTP 서비스 확인
	echo "4. SMTP 서비스 확인" >>result_2
	if ps -ef | grep sendmail | grep -qv "grep"; then
		echo " SMTP 서비스 활성화되어 있습니다." >>result_2

		if [ -f /etc/mail/sendmail.cf ]; then
			# sendmail.cf 파일이 존재하는 경우
			if grep -q -i "GreetingMessage" /etc/mail/sendmail.cf && grep -q -i "Sendmail" /etc/mail/sendmail.cf; then
				echo "BAD" >> banner
				#echo "/etc/mail/sendmail.cf 파일 내용"  >>result_3
				#cat /etc/mail/sendmail.cf | grep -i "GreetingMessage"  >>result_3
			else
				echo "GOOD" >> banner
				#echo "/etc/mail/sendmail.cf 파일 내용" >>result_3
				#cat /etc/mail/sendmail.cf | grep -i "GreetingMessage" >>result_3
			fi
		else
			echo "미점검" >> banner
			echo "/etc/mail/sendmail.cf 파일 존재하지 않습니다." >>result_2
			
		fi
	else
		echo "GOOD" >> banner
		echo " SMTP 서비스 비활성화되어 있습니다."  >>result_2
		
	fi

	# DNS 서비스 확인
	echo "5. DNS 서비스 확인" >>result_2
	if ps -ef | grep named | grep -qv "grep"; then
		echo " DNS 서비스 활성화되어 있습니다." >>result_2

		if [ -f /etc/named.conf ]; then
			# named.conf 파일이 존재하는 경우
			if grep -q "version" /etc/named.conf; then
				echo "/etc/named.conf 파일에 버전 정보가 포함되어 있습니다."  >>result_2
				echo "GOOD" >> banner

			else
				echo "/etc/named.conf 파일에 버전 정보가 포함되어 있지 않습니다." >>result_2
				echo "BAD" >> banner

			fi
		else
			echo "미점검" >> banner
			echo " /etc/named.conf 파일 존재하지 않습니다." >>result_2

		fi
	else
		echo "GOOD" >> banner
		echo " DNS 서비스 비활성화되어 있습니다." >>result_2

	fi

	if grep -q "BAD" banner; then
		echo "N"
	else
		echo "Y"
	fi

	echo "$(cat result_2)"


	echo "$(cat result_3)"


	rm -rf ssh-banner banner telnetbanner result_2 result_3

}
U_68