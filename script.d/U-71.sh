#!/bin/sh

#Apache 환경설정 관련
web='default'
path='none'
if [ `ps -ef | egrep -i "httpd|apache2" | grep -v "grep" | grep -v "ns-httpd" | grep -i -v "IBM" | grep -i -v "ihs" | grep -i -v "ohs" | grep -v "lighttpd" | grep -v "abio_httpd" | wc -l` -ge 1 ]
then 	
	if [ `ps -ef | egrep -i "httpd|apache2" | grep -v "ns-httpd" | grep -v "grep" | grep -i -v "IBM" | grep -i -v "ihs" | grep -i -v "ohs" | grep -v "lighttpd" | grep -v "abio_httpd" | awk -F' ' '{print $8}' | grep "/" | grep -v "httpd.conf" | uniq | wc -l` -ge 1 ]
	then
		web='httpd'
		ps -ef | egrep -i "httpd|apache2" | grep -v "ns-httpd" | grep -v "grep" | awk -F' ' '{print $8}' | grep "/" | grep -v "httpd.conf" | uniq >> webdir.txt
		webdir=`cat -n webdir.txt | grep 1 | awk -F' ' '{print $2}'`
		
		($webdir -V >pathinfo.txt)  2>error.txt
		
		if [ -s pathinfo.txt ]
		then
			apache=`$webdir -V | grep -i "httpd_root" | awk -F'"' '{print $2}'`
			conf=`$webdir -V | grep -i "server_config_file" | awk -F'"' '{print $2}'`
			if [ ! -f $conf ]
			then
				path='ok'
				conf="$apache/$conf"
				docroot=`cat "$conf" |grep DocumentRoot |grep -v '\#'|awk -F'"' '{print $2}'`
				svrroot=`cat "$conf" |grep ServerRoot |grep -v '\#'|awk -F'"' '{print $2}'`
				svrroot=${svrroot:-"$apache"}
			fi
			#docroot=`cat $conf | grep -i documentroot  | grep -v '#' | awk -F'"' '{print $2}'`
		fi
		#docroot=`cat $conf | grep -i documentroot  | grep -v '#' | awk -F'"' '{print $2}'`
		rm -rf webdir.txt
		#$webdir -v 
		apachev=`$webdir -v`
	elif [ `ps -ef | egrep -i "httpd|apache2" | grep -v "ns-httpd" | grep -v "grep" | grep -i -v "IBM" | grep -i -v "ihs" | grep -i -v "ohs" | grep -v "lighttpd" | grep -v "abio_httpd" | awk -F' ' '{print $9}' | grep "/" | grep -v "httpd.conf" | uniq | wc -l` -ge 1 ]
	then
		web='httpd'
		ps -ef | egrep -i "httpd|apache2" | grep -v "ns-httpd" | grep -v "grep" | grep -i -v "IBM" | grep -i -v "ohs" | awk -F' ' '{print $9}' | grep "/" | grep -v "httpd.conf" | uniq >> webdir.txt
		webdir=`cat -n webdir.txt | grep 1 | awk -F' ' '{print $2}'`
		
		#($webdir -V >pathinfo.txt ) 
		
		if [ -s pathinfo.txt ]
		then
			apache=`$webdir -V | grep -i "httpd_root" | awk -F'"' '{print $2}'`
			conf=`$webdir -V | grep -i "server_config_file" | awk -F'"' '{print $2}'`
			#echo $conf
			if [ ! -f $conf ]
			then
				path='ok'
				conf="$apache/$conf"
				#echo $conf
				docroot=`cat "$conf" |grep DocumentRoot |grep -v '\#'|awk -F'"' '{print $2}'`
				svrroot=`cat "$conf" |grep ServerRoot |grep -v '\#'|awk -F'"' '{print $2}'`
				svrroot=${svrroot:-"$apache"}
			fi
			#docroot=`cat $conf | grep -i documentroot  | grep -v '#' | awk -F'"' '{print $2}'`
		fi
		#docroot=`cat $conf | grep -i documentroot | grep -v '#' | awk -F'"' '{print $2}'`
		rm -rf webdir.txt
		#$webdir -v 
	else
		#echo "Apache 환경 변수 세팅 미흡. 수동점검 필요" 
		:
	fi	
else
	#echo "Apache 서비스 비활성화"
	:
fi


U_71() {

    touch result_2 result_3

	if [ $web = 'default' ]
	then
		echo 'Apache 서비스 비활성화되어 있습니다.' >>result_2
		
		echo "Y" 
	else
		if [ $path = 'ok' ]
		then	
			# 파일 현황
             #httpd.conf 파일 체크 로직
			if [ -f $conf ]  
			#cat $conf >> result_3
			then
                #ServerTokens 체크 로직
				if [ `cat "$conf" | grep -i "ServerTokens" | wc -l` -eq 1 ] 
				cat $conf | grep -i "ServerTokens"  >> result_3
				then
					
					if [ `cat "$conf" | grep -v "#" | grep -i "ServerTokens" | awk '{print $2}' | grep -i "prod" | wc -l` -eq 1 ]
					then
                        echo "ServerToken이 Prod로 설정되어 있습니다." >>result_2
						result3_1_1='Good' #ServerTokens 값이 prod인 경우
					else
                        echo "ServerToken이 Prod로 설정되어 있지 않습니다." >>result_2
						result3_1_1='Bad' #ServerTokens 값이 prod인 아닌 경우
					fi
				else
					echo 'ServerToken 지시자가 존재하지 않습니다.' >>result_2
					result3_1_1='Bad'
				fi
				
				#serversignature 체크 로직
				if [ `cat "$conf" | grep -i "ServerSignature" | wc -l` -eq 1 ] 
				cat $conf | grep -i "ServerSignature"  >> result_3
				then
				
					if [ `cat "$conf" | grep -v "#" | grep -i "ServerSignature" | awk '{print $2}' | grep -i "off" | wc -l` -eq 1 ]
					then
                        echo "ServerSignature이 off로 설정되어 있습니다."  >>result_2
						result3_1_2='Good' #ServerSignature의 값이 off인 경우 
					else
                        echo "ServerSignature이 off로 설정되어 있지 않습니다."  >>result_2
						result3_1_2='Bad' #ServerSignature의 값이 off인 아닌 경우 
					fi
				else
					echo 'ServerSignature 지시자가 존재하지 않습니다.'  >>result_2
					result3_1_2='Good'
				fi
			
			else
				echo ''$conf' 파일이 존재하지 않습니다.'  >>result_2
			fi


			#/extra/httpd-default 파일 체크 로직
			if [ `cat "$conf" | grep Include | grep -v '\#' | grep httpd-default.conf | wc -l` -eq 1 ] 
			then
				if [ -f "$apache"/extra/httpd-default.conf ]
				then
					#servertoken 체크 로직
					if [ `cat "$apache"/extra/httpd-default.conf | grep -i "ServerTokens" | wc -l` -eq 1 ] 
					then
						cat "$apache"/extra/httpd-default.conf | grep -i "ServerToken"  >> result_3 
						
						if [ `cat "$apache"/extra/httpd-default.conf | grep -v "#" | grep -i "ServerTokens" | awk '{print $2}' | grep -i "prod" | wc -l` -eq 1 ]
						then
							echo "/extra/httpd-default.conf 파일에 ServerTokens이 Prod로 설정되어 있습니다." >>result_2
							result3_1_1='Good' #ServerTokens 
						else
							echo "/extra/httpd-default.conf 파일에 ServerTokens이 Prod로 설정되어 있지 않습니다." >>result_2
							result3_1_1='Bad' #ServerTokens 
						fi
					else
						echo 'ServerToken 지시자가 존재하지 않습니다.' >>result_2
						result3_1_1='Bad'
					fi

					#serversignature 체크 로직
					if [ `cat "$apache"/extra/httpd-default.conf | grep -i "ServerSignature" | wc -l` -eq 1 ] 
					then
						cat $apache/extra/httpd-default.conf | grep -i "ServerSignature" >> result_3
					
						if [ `cat "$apache"/extra/httpd-default.conf | grep -v "#" | grep -i "ServerSignature" | awk '{print $2}' | grep -i "off" | wc -l` -eq 1 ]
						then
							echo "/extra/httpd-default.conf파일의 ServerSignature이 off로 설정되어 있습니다."  >>result_2
							result3_1_2='Good' #ServerSignature 
						else
							echo "/extra/httpd-default.conf파일의 ServerSignature이 off로 설정되어 있지 않습니다."  >>result_2
							result3_1_2='Bad' #ServerSignature 
						fi
					else
						echo 'ServerSignature 지시자가 존재하지 않습니다.'   >>result_2
						result3_1_2='Good'
					fi
				else
					echo $apache'/extra/httpd-default.conf 파일이 존재하지 않습니다.'   >>result_2
				fi
			else
				echo '설정 파일에 'httpd-default.conf'을 포함하고 주석처리되지 않은 줄이 하나도 없습니다.' >> result_2
			fi
			 

			if [ $result3_1_1 = 'Good' -a $result3_1_2 = 'Good' ]
			then
				echo "Y" 
			else
				echo "N" 
			fi
		fi		
	fi

    echo "$(cat result_2)"
    echo "$(cat result_3)"

    rm -rf result_2 result_3

}

U_71

