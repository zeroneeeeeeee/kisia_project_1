#!/bin/bash

# OS 버전 확인 (No LSB modules are available 메시지 제거)
os_version=$(lsb_release -a 2>/dev/null | grep -v "No LSB modules are available")

# 결과 출력
echo "N/A"
echo "OS 버전을 출력합니다. 해당 결과를 담당자와 확인하시길 바랍니다."
echo "$os_version"
