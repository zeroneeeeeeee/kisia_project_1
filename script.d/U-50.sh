#!/bin/bash

# /etc/group 파일의 경로
GROUP_FILE="/etc/group"

# /etc/group 파일 존재 여부 확인
# if ! -f 파일이 존재하지 않으면 참
if [ ! -f "$GROUP_FILE" ]; then
    echo "Y"
    echo "/etc/group 파일을 찾을 수 없습니다"
    result=$(ls /etc/group 2>/dev/null)
    echo "$result"
    # exit 1 삭제
else
    # root 그룹의 내용을 가져옴
    # /etc/group 파일에서 root로 시작하는 줄을 찾아서 변수에 저장
    root_line=$(grep "^root:" $GROUP_FILE)

    # root 그룹이 파일에 없는 경우
    if [ -z "$root_line" ]; then # if -z : 변수가 비어있으면, 참
        echo "N/A"
        echo "관리자 그룹에 불필요한 계정 등록 여부를 확인할 수 없습니다"
        echo "/etc/group 파일에 root 그룹이 없음"
    else
        # root 그룹에서 계정 분리 (첫 번째 필드는 그룹명, 두 번째는 패스워드, 세 번째는 GID, 네 번째는 멤버들)
        # IFS 부분 : root_line에서 구분자 ':'를 기준으로 필드를 분리하여 root_group 배열에 저장
        # root_members 부분 : 그룹의 네 번째 필드(계정 목록)를 개행 문자로 분리하여 저장
        IFS=':' read -r -a root_group <<< "$root_line"
        root_members=$(echo "${root_group[3]}" | tr ',' '\n')

        # root 계정만 있는지 확인
        unnecessary_accounts=0
        for member in $root_members; do
            if [ "$member" != "root" ] && [ ! -z "$member" ]; then
                unnecessary_accounts=1
                break
            fi
        done

        if [ "$unnecessary_accounts" -eq 0 ]; then # if -eq 0 : 0이면 Y, 아니면 N
            echo "Y"
            echo "관리자 그룹에 불필요한 계정이 등록되어 있지 않습니다"
        else
            echo "N"
            echo "관리자 그룹에 불필요한 계정이 등록되어 있습니다"
        fi

        # root 그룹의 내용 출력
        echo "$root_line"
    fi
fi
