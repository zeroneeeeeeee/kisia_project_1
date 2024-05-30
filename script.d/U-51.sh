#!/bin/bash

# 파일 경로 정의
GROUP_FILE="/etc/group"
PASSWD_FILE="/etc/passwd"

# 파일 존재 여부 확인
if [[ ! -f "$GROUP_FILE" ]] || [[ ! -f "$PASSWD_FILE" ]]; then
  echo "Y"
  echo "/etc/group 파일과 /etc/passwd 파일 모두 찾을 수 없습니다"
  result=$(ls /etc/group 2>&1; ls /etc/passwd 2>&1)
  echo "$result"
  # 스크립트를 여기에서 종료하지 않고 계속 진행시키기
else
  # 수동 점검 필요 결과 출력
  echo "N/A"
  echo "/etc/group 파일을 열어 group 명단을 출력하고, /etc/passwd 파일에서 로그인 쉘이 정해져있는 계정들 목록만 출력합니다. 비교 후 담당자와 상의하시길 바랍니다"

  # 파일 내용을 하나의 변수에 결합
  combined_output="---- /etc/group start ----\n$(cat /etc/group)\n---- /etc/group end ----\n---- /etc/passwd start ----\n$(cat /etc/passwd | grep bash)\n---- /etc/passwd end ----"

  # 결합된 변수를 사용하여 내용 출력
  echo -e "$combined_output"
fi

# 스크립트가 성공적으로 실행되었음을 나타내는 메시지 (Ansible 호환성을 위해)
echo "Script completed successfully"
