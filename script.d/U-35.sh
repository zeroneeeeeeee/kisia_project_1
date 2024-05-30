#!/bin/bash

# /etc/apache2/apache2.conf 파일의 위치 지정
APACHE_CONF="/etc/apache2/apache2.conf"

# 파일 존재 여부 확인
if [ ! -f "$APACHE_CONF" ]; then
    echo "Y"
    echo "Apache2.conf 파일을 찾을 수 없습니다"
    result=$(ls /etc/apache2)
    echo "$result"

else
    # 파일이 존재하는 경우, Options Indexes 옵션을 포함하는 디렉토리 찾기
    directories_with_indexes=$(awk '
    /^#/{next} # 주석 처리된 라인은 무시
    /<Directory /,/<\/Directory>/{
        if (/^#/){ next } # 섹션 내의 주석 처리된 라인 무시
        if (/Options Indexes/){ in_section_with_indexes=1 }
        if (/^<Directory /){
            in_section=1
            section=""  # 섹션 시작 시 내용 초기화
        }
        if (in_section){
            section=section?section ORS $0:$0
        }
        if (/^<\/Directory>/ && in_section){
            if(in_section_with_indexes){
                print section  # Options Indexes가 포함된 섹션 출력
                found=1
            }
            in_section=0
            in_section_with_indexes=0
            section=""
        }
    }

  END {
        if (!found) print "Y\nU-39. Indexes 옵션 사용이 제한되었습니다\napache2.conf 파일에서 모든 디렉토리에 Options Indexes 옵션이 없습니다"
    }' "$APACHE_CONF")

    # Options Indexes 옵션이 한 번이라도 발견된 경우, 해당 섹션 출력
    if [[ $directories_with_indexes == *"Options Indexes"* ]]; then
        echo "N"
        echo "Indexes 옵션 사용이 제한되지 않았습니다."
        echo "$directories_with_indexes"
    else
        # Options Indexes가 전혀 발견되지 않은 경우
        echo "Y"
        echo "Indexes 옵션 사용이 제한되었습니다."
        echo "$directories_with_indexes"
    fi
fi