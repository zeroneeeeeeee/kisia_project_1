#!/bin/bash

####################################
###################################


U_67() {

	#SNMP 서비스 여부
	if [ `ps -ef | grep snmp | grep -v "grep" | wc -l` -ge 1 ]
    then
    	
        #ps -ef | grep snmp | grep -v "grep"
    	echo "SNMP가 활성화되어 있습니다. "  >> result_2
		

		#설정파일 CommunityString 현황
   
		SPCONF_DIR="/etc/snmpd.conf /etc/snmpdv3.conf /etc/snmp/snmpd.conf /etc/snmp/conf/snmpd.conf /etc/sma/snmp/snmpd.conf"
		
		for file in $SPCONF_DIR
		do
			if [ -f $file ]
			then
				#파일 내 CommunityString 설정
				cat $file | grep  com2sec 
                #public,private 필터링
				snmpconf_public_private_count=$(grep -vE '^#|^\s#' "$file" | grep -iE 'public|private' | wc -1)

				if [ "$snmpconf_public_private_count" -eq 0 ]; then
					echo "GOOD" >> commnunity
				else
					echo "BAD" >> commnunity
				fi
				
			fi
		done
	else
		echo "SNMP가 비활성화되어 있습니다. "  >> result_2
		echo "GOOD" >> commnunity
	fi
	
	if [ `cat commnunity | grep -i "BAD" | wc -l` -eq 0 ]
	then
		echo "Y" 
	else
		echo "N" 
	fi

	echo "$(cat result_2)"

    SPCONF_DIR="/etc/snmpd.conf /etc/snmpdv3.conf /etc/snmp/snmpd.conf /etc/snmp/conf/snmpd.conf /etc/sma/snmp/snmpd.conf"


    # result_3 파일에 대한 출력을 루프 밖으로 이동
    for conf_file in $SPCONF_DIR; do
        if [ -f "$conf_file" ]; then
            ls -alL "$conf_file" >> result_3
        else
            echo "$conf_file 파일이 존재하지 않습니다." >> result_3
        fi 
    done

    echo "$(cat result_3)"


	rm -f commnunity result_2 result_3
	
}
U_67