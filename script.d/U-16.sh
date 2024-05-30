#!/bin/bash

if [ `find /dev -type f 2>/dev/null | wc -l` -gt 0 ]; then
	echo "N"
	echo "/dev 디렉터리에 존재하지 않는 device 파일이 존재합니다."
	echo "`find /dev -type f 2>/dev/null`"
else 
	echo "Y"
	echo "/dev 디렉터리에 존재하지 않는 device 파일이 존재하지 않습니다."
	echo "`find /dev -type f 2>/dev/null`"
fi
