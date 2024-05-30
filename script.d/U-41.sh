#!/bin/bash

# apache2.conf 파일 경로
CONFIG_FILE="/etc/apache2/apache2.conf"

# DocumentRoot 경로 확인용 기본 디렉토리 목록
DEFAULT_DIRS=("/usr/local/apache/htdocs" "/usr/local/apache2/htdocs" "/var/www/html")

# CONFIG_FILE 존재 여부 확인
# if ! -f : 존재하지 않으면 참 출력
if [ ! -f "$CONFIG_FILE" ]; then
    result=$(ls "$CONFIG_FILE"  2>/dev/null) 
    # 2>&1 : 파일이 존재하지 않을 경우의 에러 메시지를 포착
    echo "Y"
    echo "/etc/apache2/apache2.conf 파일이 존재하지 않습니다"
    echo "$result"
    exit 0
fi

# DocumentRoot 설정 값을 추출
# grep -Po : Perl 호환 정규 표현식 사용 + 매치된 부분 출력
# '^\s*' : 라인 시작 후 임의의 공백 무시
# 'DocumentRoot\s+" : DocumentRoot 다음 하나 이상의 공백과 따옴표가 오는 부분 탐색
# '\K' : 이전에 일치한 부분 결과 제외
# '[^"]+ : 따옴표가 아닌 문자들을 일치시켜 실제 경로만 추출
document_root=$(grep -Po '^\s*DocumentRoot\s+"\K[^"]+' "$CONFIG_FILE")

# DocumentRoot 설정 값 확인
# if -z : 변수가 비었으면, true 반환 
if [ -z "$document_root" ]; then
    echo "N/A"
    echo "DocumentRoot의 디렉토리를 확인할 수 없습니다"
    echo "$document_root"

else
    # 설정된 DocumentRoot가 기본 디렉토리 목록에 속하는지 확인
    is_default_dir="N"
    for dir in "${DEFAULT_DIRS[@]}"; do
        if [ "$document_root" == "$dir" ]; then
            is_default_dir="Y"
            break
        fi
    done

    # 출력 조건에 따라 결과 출력
    if [ "$is_default_dir" == "Y" ]; then
        echo "N"
        echo "DocumentRoot를 기본 디렉토리로 지정했습니다"
        echo "\"$document_root\""
    else
        echo "Y"
        echo "DocumentRoot를 별도의 디렉토리로 지정했습니다"
        echo "\"$document_root\""
    fi
fi

