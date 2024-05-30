#!/bin/bash

# Apache 설정 파일의 경로를 변수에 저장
apache_conf="/etc/apache2/apache2.conf"

# Apache 설정 파일의 존재 여부를 확인
if [ ! -f "$apache_conf" ]; then
  # 파일이 존재하지 않는 경우 N/A 결과를 출력
  echo "Y"
  echo "/etc/apache2/apache2.conf 파일을 찾을 수 없습니다."
  # /etc/apache2 디렉토리의 파일 목록을 result 변수에 저장
  result=$(ls /etc/apache2/apache2.conf 2>/dev/null)  # 오류 메시지를 숨김
  # 파일 목록 출력
  echo "$result"
  exit 0
fi

# awk를 사용하여 apache2.conf 파일 분석 시작
result=$(awk '
/<Directory / {  # Directory 태그 시작을 발견하면
  dir=$2  # 디렉토리 경로 저장
  allowoverride="None"  # 기본값으로 AllowOverride를 None으로 설정
  in_directory=1  # 디렉토리 내부임을 표시하는 플래그 설정
}
/AllowOverride/ && in_directory {  # AllowOverride 설정을 발견하면
  if ($2 != "None") {
    allowoverride=$2  # None이 아니라면 값을 업데이트
  }
}
/Require/ && in_directory {  # Require 태그를 만나면
  in_directory=0  # 디렉토리 블록의 끝
  if (allowoverride == "None") {  # AllowOverride가 None이면
    none_dirs[none_count++]=dir  # None 디렉토리 목록에 추가
  } else {
    other_dirs[other_count++]=dir " - " allowoverride  # 그 외 설정 목록에 추가
  }
}
END {  # 모든 줄을 처리한 후
  if (none_count > 0) {  # None 설정이 하나라도 있으면
    print "N"
    for (i in none_dirs) print "<Directory " none_dirs[i] ">\n\tOptions Indexes FollowSymLinks\n\tAllowOverride None\n\tRequire all granted\n</Directory>"
  } else if (other_count > 0) {  # None이 아닌 설정이 하나라도 있으면
    print "Y"
    for (i in other_dirs) print "<Directory " substr(other_dirs[i], 1, index(other_dirs[i], " -") - 1) ">\n\tOptions Indexes FollowSymLinks\n\tAllowOverride " substr(other_dirs[i], index(other_dirs[i], " - ") + 3) "\n\tRequire all granted\n</Directory>"
  } else {  # 설정이 전혀 없으면
    print "Y"
  }
}' $apache_conf)

# 결과 출력
status=$(echo "$result" | head -n1)  # 결과의 첫 번째 줄(상태) 추출
echo "$status"
if [ "$status" = "N" ]; then
  echo "상위 디렉토리에 이동제한이 설정되어 있지 않습니다"
elif [ "$status" = "Y" ]; then
  echo "상위 디렉토리에 이동제한이 설정되어 있습니다"
else
  echo "파일 내 AllowOverride 지시자를 확인할 수 없습니다."
fi
echo "$result" | tail -n +2  # 결과의 첫 번째 줄을 제외하고 출력
