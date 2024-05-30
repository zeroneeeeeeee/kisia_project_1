#!/bin/sh

#########################
#########################

U_70() {

	#Sendmail 프로세스 확인
	if [ `ps -ef | grep sendmail | grep -v "grep" | wc -l` -eq 0 ]
    then
		echo "Sendmail 서비스가 비활성화되어 있습니다." >> result_2
    else
        echo "Sendmail 서비스가 활성화되어 있습니다." >> result_2
		
	fi
	

	if [ `ps -ef | grep sendmail | grep -v "grep" | wc -l` -gt 0 ]
	then
		#/etc/mail/sendmail.cf 파일의 옵션 확인
		if [ -f /etc/mail/sendmail.cf ]
		then    
                echo "/etc/mail/sendmail.cf 파일이 존재합니다." >> result_2
			 	
			else
				echo "/etc/mail/sendmail.cf 파일이 존재하지 않습니다." >> result_2
			fi
			
	fi

	if [ `ps -ef | grep sendmail | grep -v "grep" | wc -l` -eq 0 ]
    then
		echo "Y" 
    else
		if [ -f /etc/mail/sendmail.cf ]
		then
			if [ `cat /etc/mail/sendmail.cf | grep -i "O PrivacyOptions" | grep -i "noexpn" | grep -i "novrfy" | grep -v "^#" |wc -l ` -eq 1 ]
			then
				echo "Y" 
            elif [ `cat /etc/mail/sendmail.cf | grep -i "O PrivacyOptions" | grep -i "goaway" | grep -v "^#" |wc -l ` -eq 1 ]
			then
				echo "Y"
			else
				echo "N" 
			fi
        else
          echo "Y" 
		fi
	fi


    echo "$(cat result_2)"
    
    ps -ef | grep sendmail | grep -v "grep"  >> result_3
    cat /etc/mail/sendmail.cf | grep -i "O PrivacyOptions" >>result_3
    echo "$(cat result_3)"

	rm -rf result_2 result_3
}

U_70
