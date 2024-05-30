#!/bin/bash

if [ `echo $PATH | grep -E '\.:|::|:.:' | wc -l` -gt 0 ]; then
	echo "N"
	echo "PATH 환경 변수 내에 "." 또는 "::" 또는 ":.:"이 포함되어 있습니다."
	echo "`echo $PATH | grep -E '\.:|::|:.:'`"
else 
	echo "Y"
	echo "PATH 환경 변수 내에 "." 또는 "::" 또는 ":.:"이 포함되어 있지 않습니다"
	echo "`echo $PATH | grep -E '\.:|::|:.:'`"
fi   