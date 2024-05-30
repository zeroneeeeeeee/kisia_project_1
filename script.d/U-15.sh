#!/bin/bash

world_writable_files=()
if [ `find / -type f -perm -2 2>/dev/null | wc -l` -gt 0 ]; then
	echo "N"
	echo "world writable 설정이 되어있는 파일이 있습니다."
	world_writable_files+=(`find / ! \( -path '/proc*' -prune \) -type f -perm -2 2>/dev/null`)
	echo "${world_writable_files[@]}"
else 
	echo "Y"
	echo "world writable 설정이 되어있는 파일이 존재하지 않습니다."
	world_writable_files+=(`find / ! \( -path '/proc*' -prune \) -type f -perm -2 2>/dev/null`)
	echo "${world_writable_files[@]}"
fi