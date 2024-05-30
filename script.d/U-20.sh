#!/bin/bash

# 파일 경로를 변수에 저장
file_path="/etc/passwd"

# 파일 내에서 'anonymous:'로 시작하는 행을 찾아보고, 해당 행이 존재하면 'N'을 출력합니다.
if grep -qE "^anonymous:" "$file_path"; then
    echo "N" >> file1
else
    echo "Y" >> file1
fi

# /etc/group 파일 내에서 'anonymous:'로 시작하는 행을 찾아보고, 해당 행이 존재하면 'N'을 출력합니다.
# 그렇지 않으면 'Y'를 출력
if grep -qE "^anonymous:" /etc/group; then
    echo "N" >> file1
else
    echo "Y" >> file1
fi

# 파일에서 'N'을 찾아서 익명 FTP 접속을 확인합니다.
if grep -q "N" file1; then
    echo "N"
    echo "Anonymous FTP (익명 ftp) 접속을 차단하지 않았습니다."
else
    echo "Y"
    echo "Anonymous FTP (익명 FTP) 접속을 차단하였습니다."
fi

# /etc/passwd 파일에서 "ftp"를 포함하는 줄이 있는지 확인합니다.
if grep -q "ftp" /etc/passwd; then
    # "ftp"를 포함하는 줄이 있다면, "ftp" 사용자가 존재합니다.
    echo "ftp 사용자가 존재합니다."
else
    # "ftp"를 포함하는 줄이 없다면, "ftp" 사용자가 존재하지 않습니다.
    echo "ftp 사용자가 존재하지 않습니다."
fi

# 파일 삭제
rm file1
