#!/bin/sh

###################################
###################################

#수동점검 항목

U_59() {

	  find /tmp -name ".*" -ls 2>/dev/null  > hidden-file
	find /home -name ".*" -ls 2>/dev/null | egrep -v ".bash|viminfo|mozilla" >> hidden_file 2>&1
	find /usr -name ".*" -ls 2>/dev/null |  grep -v "root" | grep -v "var" >> hidden_file 2>&1
	find /var -name ".*" -ls 2>/dev/null |  grep -v "root" | grep -v "var" >> hidden_file 2>&1
    find /bin -name ".*" -ls 2>/dev/null |  grep -v "root" | grep -v "var" >> hidden_file 2>&1
	find /sbin -name ".*" -ls 2>/dev/null |  grep -v "root" | grep -v "var" >> hidden_file 2>&1
	#find / -type f -name ".*" -exec ls -l {} \; >> hidden-file.igloo 2>&1
	#find / -type d -name ".*" -exec ls -l {} \; >> hidden-file.igloo 2>&1
	

	if [ -s hidden_file ] #파일이 있으면 참
    then
        echo "N/A" #수동점검
        echo "숨겨진 파일 및 디렉터리가 존재합니다." 
		cat hidden_file 
		
    else
        echo "Y"
		echo "숨겨진 파일 및 디렉터리가 존재하지 않습니다." 
		cat hidden_file
	fi

	rm -rf hidden_file

}

U_59
