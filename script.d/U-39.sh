#!/bin/bash

# /etc/apache2/apache2.conf 파일의 위치 지정
CONF_FILE="/etc/apache2/apache2.conf"

# 파일 존재 여부 확인
if [ ! -f "$CONF_FILE" ]; then
    # if -f : 파일이 존재하지 않는 경우 N/A 출력
    echo "Y"
    echo "apache2.conf 파일을 찾을 수 없습니다"
    result=$(ls /etc/apache2 2>/dev/null)
    echo "$result"

else
    # 파일이 존재하는 경우, FollowSymLinks 옵션을 포함하는 디렉토리 찾기
    # awk : 파일에서 특정 필드 출력
    directories_with_followsymlinks=$(awk '
    /^#/{next} 
    /<Directory /,/<\/Directory>/{
        if (/^#/){ next } # 주석 처리된 라인은 무시
        if (/FollowSymLinks/){ in_section_with_symlinks=1 }
        if (/^<Directory /){
            in_section=1
            section=""  # 섹션 시작 시 내용 초기화
        }
        if (in_section){
            section=section?section ORS $0:$0
        }
        if (/^<\/Directory>/ && in_section){
            if(in_section_with_symlinks){
                print section  # FollowSymLinks가 포함된 섹션 출력
                found=1
            }
            in_section=0
            in_section_with_symlinks=0
            section=""
        }
    }
    END {
        if (!found) print "Y\nU-39. 심볼릭 링크, aliases 사용이 제한되었습니다\napache2.conf 파일에서 모든 디렉토리에 FollowSymLinks 옵션이 없습니다"
    }' "$CONF_FILE")
    # '/<Directory /,/<\/Directory>/' : <Directory> 태그로 시작해서 </Directory> 태그로 끝나는 부분을 선택
    # '{print; if (/FollowSymLinks/){found=1}}' : 각 선택된 부분을 출력하고, FollowSymLinks가 있을 경우 found 변수를 1로 설정
    # 'END {if (!found)...}' : 모든 처리가 끝난 후, found 변수가 설정되지 않았다면, 즉 FollowSymLinks 옵션이 한 번도 발견되지 않았다면 특정 메시지를 출력

    if [[ $directories_with_followsymlinks == *"FollowSymLinks"* ]]; then
        # FollowSymLinks 문자열이 한 번이라도 발견된 경우, 해당 섹션 출력
        echo "N"
        echo "심볼릭 링크, aliases 사용이 제한되지 않았습니다"
        echo "$directories_with_followsymlinks"
   
    else
        # FollowSymLinks가 전혀 발견되지 않은 경우
        echo "Y"
        echo "심볼릭 링크, aliases 사용이 제한되었습니다"
        echo "$directories_with_followsymlinks"
    fi
fi

