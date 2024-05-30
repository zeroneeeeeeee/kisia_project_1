#!/bin/bash

check_permission() {
    file_path=$1
    if [ -f "$file_path" ]; then
        perm=$(stat -c "%a" "$file_path")
        owner=$(stat -c "%U" "$file_path")
        if [ "$owner" != "root" ] || [ "$perm" -gt 640 ]; then
                echo "N" >> file
                return
        fi
    fi
    echo "Y" >> file
}
# 배열 선언
declare -a cron_files
declare -a cron_directories

# crontab 파일 경로
crontab_path=("/usr/bin/crontab" "/usr/sbin/crontab" "/bin/crontab" "$(which crontab 2>/dev/null)")

# crontab 파일 권한 확인
for path in "${crontab_path[@]}"; do
    check_permission "$path"
done

# cron 디렉토리
cron_directories=("/etc/cron.hourly" "/etc/cron.daily" "/etc/cron.weekly" "/etc/cron.monthly" "/var/spool/cron" "/var/spool/cron/crontabs")

# cron 디렉토리 내 파일 권한 확인
for dir in "${cron_directories[@]}"; do
    if [ -d "$dir" ]; then
        for file in "$dir"/*; do
            [ -f "$file" ] && cron_files+=("$file")
        done
    fi
done

# 파일 권한 확인
for file in "${cron_files[@]}"; do
    check_permission "$file"
done | sort -u | head -n 1

if [ `cat file | grep "N" | wc -l` -gt 0 ]
    then
      echo "N"
      echo "crontab 명령어 일반사용자 사용가능하거나, crond 관련 파일 640 이상입니다. "
else
      echo "Y"
      echo "crontab 명령어 일반사용자 금지 및 cron 관련 파일 640 이하입니다."
fi
S=$(ls -l /usr/bin/crontab | rm file)
echo "$S"