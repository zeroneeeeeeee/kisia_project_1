#!/bin/bash

if [ `awk -F : '$2!="x"' /etc/passwd | wc -l` -gt 0 ]; then
	echo "N"
	echo "쉐도우 패스워드를 사용하고 있지 않습니다."
	echo "`awk -F : '$2!="x"' /etc/passwd`"
else 
	echo "Y"
	echo "쉐도우 패스워드를 사용하고 있습니다."
	echo "`awk -F : '$2!="x"' /etc/passwd`"
fi