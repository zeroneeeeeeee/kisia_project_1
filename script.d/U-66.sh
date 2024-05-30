#!/bin/sh

############################
############################


U_66() {

    #SNMP 서비스 여부 확인
	if [ `ps -ef | grep snmp | egrep -v "grep|disabled" | wc -l` -eq 0 ]
    then
		echo "SNMP가 비활성화되어 있습니다. " >>result_2
    else
        echo "SNMP가 활성화되어 있습니다. "  >>result_2
	fi
    ps -ef | grep snmp | egrep -v "grep|disabled" >> result_3

	if [ `ps -ef | grep snmp | egrep -v "grep|disabled" | wc -l` -eq 0 ]
    then
		echo "Y"
	else
		echo "N" 
	fi

   echo "$(cat result_2)"
   echo "$(cat result_3)"

    rm -rf result_2 result_3
}
U_66
