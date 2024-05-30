#!/bin/bash

###################################
###################################



U_63() {

    file_paths=(
        "/etc/ftpd/ftpusers"
        "/etc/ftpusers"
        "/etc/vsftpd.ftpusers"
        "/etc/vsftpd/ftpusers"
        "/etc/vsftpd.user_list"
        "/etc/vsftpd/user_list"
    )

    for file_path in "${file_paths[@]}"; do
        if [ -f "$file_path" ]; then
            if [ "$(ls -alL "$file_path" | awk '{print $1}' | grep '640' | wc -l)" -eq 1 ]; then
                if [ "$(ls -alL "$file_path" | awk '{print $3}' | grep -i "root" | wc -l)" -eq 1 ]; then
                    echo "GOOD" >> ftpusers
                    echo "$file_path 파일의 소유자 root이고 권한이 640 이하 입니다." >> result_2

                else
                    echo "BAD" >> ftpusers
                    echo "$file_path 파일의 소유자 root가 아닙니다." >> result_2

                fi
            else
                echo "BAD" >> ftpusers
                echo "$file_path 파일의 권한이 640 이하가 아닙니다." >> result_2

            fi
        else
            echo "no-file" >> ftpusers
            echo " $file_path 파일이 존재하지 않습니다." >> result_2

        fi
    done

    if [ "$(cat ftpusers | grep -i "BAD" | wc -l)" -gt 0 ]; then
        echo "N"
    else
        echo "Y"
    fi
    echo "$(cat result_2)"

    # result_3 파일에 대한 출력을 루프 밖으로 이동
    for file_path in "${file_paths[@]}"; do
        ls -alL "$file_path" >> result_3
    done

    echo "$(cat result_3)"


    rm -rf ftpusers result_2 result_3
   
}
U_63