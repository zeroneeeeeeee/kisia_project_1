#!/bin/bash

# 필요한 파일들의 존재 여부 확인
required_files="/etc/group /etc/pam.d/su /usr/bin/su"
missing_files=()

for file in $required_files; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    fi
done

# 필요한 파일이 하나라도 누락된 경우
if [ ${#missing_files[@]} -ne 0 ]; then
    echo "N/A"
    echo "다음 파일이 존재하지 않습니다: ${missing_files[*]}"
    result=$(ls ${missing_files[*]} 2>/dev/null)
    echo "$result"
    exit
fi

# wheel 그룹 존재 여부 및 그룹 내 사용자 확인
wheel_group=$(grep "^wheel:" /etc/group)
if [ -z "$wheel_group" ]; then
    echo "N"
    echo "wheel 그룹이 존재하지 않습니다"
    echo "$(grep wheel /etc/group)"
    exit
elif ! echo "$wheel_group" | grep -q ':'; then
    echo "N/A"
    echo "wheel 그룹 내 사용자가 존재하지 않습니다"
    echo "$(grep wheel /etc/group)"
    exit
fi

# /usr/bin/su 파일 권한 확인
su_permissions=$(ls -l /usr/bin/su | awk '{print $1}')
if [ "$su_permissions" != "-rwsr-x---" ]; then
    permissions_ok="N"
else
    permissions_ok="Y"
fi

# /etc/pam.d/su 파일 내 su 관련 설정 확인
pam_su_content=$(cat /etc/pam.d/su)
required_pam_configs=(
    "auth sufficient /lib/security/pam_rootok.so"
    "auth required /lib/security/pam_wheel.so debug group=wheel"
    "auth sufficient /lib/security/$ISA/pam_rootok.so"
    "auth required /lib/security/$ISA/pam_wheel.so use_uid"
)
config_ok="Y"
for config in "${required_pam_configs[@]}"; do
    if ! echo "$pam_su_content" | grep -q "$config"; then
        config_ok="N"
        break
    fi
done

# 결과 판단
if [ "$permissions_ok" = "Y" ] && [ "$config_ok" = "Y" ]; then
    echo "Y"
    echo "su 명령어를 특정 그룹에 속한 사용자만 사용하도록 제한되어 있습니다"
    echo "Permissions: $su_permissions, PAM configurations: OK"
else
    echo "N"
    echo "su 명령어를 모든 사용자가 사용하도록 설정되어 있습니다"
    echo "Permissions: $su_permissions, PAM configurations: Not fully configured"
fi
