#!/bin/bash

if [ `find / \( -nouser -or -nogroup \) 2>/dev/null | wc -l` -gt 0 ]; then
	echo "N"
	echo "소유자가 존재하지 않는 파일 및 디렉터리가 존재합니다."
	echo "`find / \( -nouser -or -nogroup \) 2>/dev/null`"
else 
	echo "Y"
	echo "소유자가 존재하지 않는 파일 및 디렉터리가 존재하지 않습니다."
	echo "`find / \( -nouser -or -nogroup \) 2>/dev/null`"
fi