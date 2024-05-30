#!/bin/sh

###################################
###################################



U_65() {

	if [ -f /usr/bin/at ]
	then
		ls -al /usr/bin/at 
		
		if [ `ls -al /usr/bin/at | awk '{print $1}' | grep ".....-.---" | wc -l` -eq 1 ]
		then
			if [ `ls -al /usr/bin/at | awk '{print $3}' | grep -i "root" | wc -l` -eq 1 ]
			then
				echo "GOOD" >> at_file
			else
				echo "/usr/bin/at 파일 소유자가 적절하지 않음"  >>result_2 
				echo "BAD" >> at_file
			fi
		else
			echo "/usr/bin/at 파일 권한이 적절하지 않음"  >>result_2
			echo "BAD" >> at_file
		fi
	else
		echo "/usr/bin/at 파일이 존재하지 않음"  >>result_2
		echo "GOOD" >> at_file
	fi

	
	# at.allow, at.deny 파일 정보 
	if [ -f /etc/at.allow ]
	then
		ls -al /etc/at.allow 
		
		
		if [ `ls -al /etc/at.allow | awk '{print $1}' | grep "...-.-----" | wc -l` -eq 1 ]
		then
            echo "/etc/at.allow 파일 권한이 적절합니다."  >>result_2
			echo "GOOD" > at_file
		else
			echo "/etc/at.allow 파일 권한이 적절하지 않습니다."  >>result_2
			
			echo "BAD" >> at_file
		fi
	fi
	

	if [ -f /etc/at.deny ]
    then
		ls -al /etc/at.deny 
		
		
		if [ `ls -al /etc/at.deny | awk '{print $1}' | grep "...-.-----" | wc -l` -eq 1 ]
		then
            echo "/etc/at.allow 파일 권한이 적절합니다."  >>result_2
			echo "GOOD" > at_file
		else
			echo "/etc/at.deny 파일 권한이 적절하지 않습니다."  >>result_2
			
			echo "BAD" >> at_file
		fi
	fi
    
	
	#at.allow, at.deny 파일 내용

	#/etc/at.allow 파일 내용
	if [ -f /etc/at.allow ]
	then
		.
	else
		echo "/etc/at.allow 파일 없음" >>result_2
	fi
	
	
	#/etc/at.deny 파일 내용 
	if [ -f /etc/at.deny ]
    then
		.
	else
		echo "/etc/at.deny 파일 없음" >>result_2
	fi
	

	if [ `cat at_file | grep -i "bad" | wc -l` -eq 0 ]
    then
		echo "Y" 
    else
		echo "N" 
	fi

    echo "$(cat result_2)"
    ls -alL /usr/bin/at  >> result_3
    ls -alL /etc/at.allow >> result_3
    ls -alL /etc/at.deny  >> result_3
    echo "$(cat result_3)"
    
		
	rm -rf at_file result_2 result_3

	
}
U_65
