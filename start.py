import os
import time
import json
import docker
import shutil
import numpy as np
import pandas as pd
import configparser as cp
from openpyxl import load_workbook

docker_image_tag = "custom_ansible_image"

current_directory = os.getcwd()

local_inventory_dir = f"{current_directory}/inventory.d/"
local_private_key_dir = f"{current_directory}/privateKey.d/"
local_result_json_dir = f"{current_directory}/result_json.d/"
local_result_excel_dir = f"{current_directory}/result_excel.d/"


local_excel_file_path = f"{current_directory}/server_info.xlsx"
local_source_excel_path = f"{current_directory}/example_excel.d/example_1.xlsx"
local_ansible_cfg_path = f"{current_directory}/ansible.cfg"
local_dockerfile_path = f"{current_directory}/dockerfile"

container_result_dir = "/root/miniproject/result.d/"
container_inventory_dir = "/root/miniproject/inventory.d/"
container_private_key_dir = "/root/miniproject/privatekey.d/"

container_playbook_path = "/root/miniproject/mainBook.yml"

client = docker.from_env()

# Ansible 설정 파일 생성 함수
def create_ansible_cfg(forks=5):
    """
    Ansible 설정 파일을 생성합니다.
    :param forks: 병렬 실행할 작업의 수 (기본값: 5)
    """
    config = cp.ConfigParser(allow_no_value=True)  # 섹션 밑에 옵션 없어도 허용하도록 설정
    config.add_section('defaults')  # 기본 설정 섹션 추가

    # 각 설정 값을 추가
    config.set('defaults', "ask_pass = false")  # 암호 요청 메시지 표시 안함
    config.set('defaults', "host_key_checking = false")  # 호스트 키 확인 비활성화
    config.set('defaults', f"forks={forks}")  # 병렬 실행할 작업의 수 설정

    # 설정 파일을 지정된 경로에 생성
    with open(local_ansible_cfg_path, "w") as configfile:
        config.write(configfile)

    print(f'create ansible.cfg file path : {local_ansible_cfg_path}')

# 인벤토리 파일 생성 함수
def create_inventory(max_num=5):
    """
    서버 정보를 포함한 인벤토리 파일을 생성합니다.
    :param max_num: 하나의 인벤토리 파일에 포함될 최대 호스트 수 (기본값: 5)
    """
    excel_column = ['os_name', 'ip', 'ssh_port', 'ssh_user_name', 'ssh_password', 'ssh_private_key_file_name', 'ssh_sudo_password']

    pd_data = pd.read_excel(local_excel_file_path)  # 엑셀 파일에서 서버 정보 읽음

    os_sections = pd_data[excel_column[0]].unique()  # 운영체제 종류 구분

    max_hosts = max_num  # 함수 인자값으로 받아서 변수 넣기

    file_count = int(np.ceil(len(pd_data) / max_hosts))  # 필요한 인벤토리 파일 수 계산

    # 각 인벤토리 파일 생성
    for i in range(file_count):
        config = cp.ConfigParser(allow_no_value=True)

        start_index = i * max_hosts
        end_index = start_index + max_hosts
        subset = pd_data.iloc[start_index:end_index]  # 서버 정보 슬라이싱

        for os_section in os_sections:
            hosts = subset[subset[excel_column[0]] == os_section]  # 운영체제별 호스트 구분

            if not hosts.empty:
                config.add_section(os_section)  # 섹션 추가
                for _, row in hosts.iterrows():  # 각 호스트 정보 인벤토리 파일 추가
                    host_line = f"{row[excel_column[1]]} ansible_host={row[excel_column[1]]} ansible_port={row[excel_column[2]]} ansible_user={row[excel_column[3]]} "
                    if pd.notna(row[excel_column[4]]):  # SSH 비밀번호가 있는 경우
                        host_line += f"ansible_ssh_pass={row['ssh_password']} "
                    if pd.notna(row[excel_column[5]]):  # SSH 개인 키 파일이 있는 경우
                        host_line += f"ansible_ssh_private_key_file={container_private_key_dir}{row[excel_column[5]]} "
                    if pd.notna(row[excel_column[6]]):  # Sudo 비밀번호가 있는 경우
                        host_line += f"ansible_become=true ansible_sudo_pass={row[excel_column[6]]}"
                    config.set(os_section, host_line)  # 호스트 라인을 섹션에 추가

        with open(f"{local_inventory_dir}inventory_{i+1}.ini", "w") as configfile:
            config.write(configfile)  # 인벤토리 파일 저장

# 커스텀 도커 이미지 체크 함수
def check_custom_docker_image(docker_image_tag):
    """
    도커 이미지가 존재하는지 확인합니다.
    :param docker_image_tag: 도커 이미지 태그
    :return: 이미지가 존재하면 이미지 객체를 반환하고, 없으면 False를 반환합니다.
    """
    try:
        docker_image = client.images.get(docker_image_tag)  # 도커 이미지 가져오기 시도
    except docker.errors.ImageNotFound:
        return False  # 이미지가 없으면 False 반환
    return docker_image  # 이미지가 있으면 이미지 객체 반환

# 커스텀 도커 이미지 생성 함수
def create_custom_docker_image(docker_image_tag):
    """
    커스텀 도커 이미지를 생성합니다.
    :param docker_image_tag: 도커 이미지 태그
    """
    # 도커파일 내용을 정의
    dockerfile_content = """FROM ubuntu:latest
    
RUN apt update && apt install -y software-properties-common \
&& add-apt-repository --yes --update ppa:ansible/ansible && \
apt install -y ansible
    
RUN mkdir -p /root/miniproject/inventory.d
RUN mkdir /root/miniproject/privatekey.d
RUN mkdir /root/miniproject/result.d
RUN mkdir /root/miniproject/script.d

COPY ./script.d/ /root/miniproject/script.d/
COPY ./yml.d/mainBook.yml /root/miniproject/mainBook.yml
COPY ./yml.d/taskBook.yml /root/miniproject/taskBook.yml
COPY ./ansible.cfg /root/miniproject/ansible.cfg

WORKDIR /root/miniproject
"""

    print(f'create docker file path : {local_dockerfile_path}')

    # 도커파일을 지정된 경로에 생성
    with open(local_dockerfile_path, 'w') as f:
        f.write(dockerfile_content)
    print(f'success docker file path : {local_dockerfile_path}')

    print(f'create docker_image_tag : {docker_image_tag}')
    image, _ = client.images.build(
        path='.',  # 현재 경로에서 빌드
        dockerfile='dockerfile',  # 도커파일 이름
        tag=docker_image_tag,  # 태그 지정
        rm=True,  # 빌드 후 임시 컨테이너 제거
        nocache=False  # 캐시 사용
    )

    # 이미지가 성공적으로 빌드되었는지 확인
    if docker_image_tag in image.tags[0]:
        print(f'success docker_image_tag : {docker_image_tag}')
    else:
        print(f'fail create docker image tag')
        print(f'end main')
        exit()  # 실패 시 프로그램 종료

# 컨테이너 실행 함수
def run_container(image_tag, num_containers=2):
    """
    Ansible 플레이북을 실행할 컨테이너를 실행합니다.
    :param image_tag: 도커 이미지 태그
    :param num_containers: 동시에 실행할 컨테이너 수 (기본값: 2)
    """
    volumes = {  # 바인드 마운트 설정
        local_result_json_dir: {'bind': container_result_dir, 'mode': 'rw'},
        local_inventory_dir: {'bind': container_inventory_dir, 'mode': 'rw'},
        local_private_key_dir: {'bind': container_private_key_dir, 'mode': 'ro'}
    }
    inventory_file_list = sorted([f for f in os.listdir(local_inventory_dir) if f.endswith('.ini')])  # .ini 파일 리스트 가져오기

    # 무한 루프로 컨테이너 실행을 관리
    while True:
        container_val = len(client.containers.list('all'))  # 현재 실행 중인 모든 컨테이너 수를 가져옴

        if container_val == int(num_containers):  # 실행 중인 컨테이너가 지정된 수에 도달하면 대기
            time.sleep(5)
            continue

        if not inventory_file_list:  # 인벤토리 파일 리스트가 비어 있으면
            if len(client.containers.list('all')) == 0:  # 모든 컨테이너가 종료된 경우
                print(f'all containers exited')
                break

        if inventory_file_list:  # 인벤토리 파일이 남아 있는 경우
            inv_file = inventory_file_list.pop(0)  # 인벤토리 파일 리스트에서 하나를 꺼냅니다.

            container = client.containers.run(
                image_tag,
                command=f"ansible-playbook mainBook.yml -i ./inventory.d/{inv_file}",  # Ansible 플레이북 실행 명령어
                detach=True,  # 백그라운드에서 실행
                volumes=volumes,  # 바인드 마운트 설정
                auto_remove=True  # 컨테이너 종료 시 자동 제거
            )

            print(f"Running container ID {container.short_id}")

        time.sleep(5)

# JSON 파일 로드 함수
def load_json_files():
    """
    결과 JSON 파일들을 로드합니다.
    :return: JSON 데이터 리스트
    """
    json_lists = []
    result_file_list = sorted([os.path.join(local_result_json_dir, f) for f in os.listdir(local_result_json_dir)])  # 결과 JSON 파일 리스트 가져오기

    for filename in result_file_list:  # 각 파일을 읽어서 JSON 데이터 리스트에 추가
        with open(filename, 'r', encoding='utf-8') as file:
            json_lists.append(json.load(file))

    return json_lists

# 한글이 포함되어 있는지 체크하는 함수
def hangul_check(text):
    """
    문자열에 한글이 포함되어 있는지 확인합니다.
    :param text: 확인할 문자열
    :return: 한글이 포함되어 있으면 True, 그렇지 않으면 False
    """
    for chat in text:
        if '\uac00' <= chat <= '\ud7a3':  # 한글 유니코드 범위를 체크
            return True
    return False

# JSON 데이터 -> 엑셀 파일 변환 함수
def one_json_to_one_excel(json_lists):
    """
    JSON 데이터를 읽어 엑셀 파일로 저장합니다.
    :param json_lists: JSON 데이터 리스트
    """
    for json_data in json_lists:  # 각 JSON 데이터를 처리
        copied_excel_path = f"{local_result_excel_dir}{json_data['ip']}_result.xlsx"

        shutil.copy(local_source_excel_path, copied_excel_path)  # 예제 엑셀 파일을 복사

        time.sleep(1)

        wb = load_workbook(copied_excel_path)
        ws = wb.active

        # IP 주소와 OS 이름을 엑셀 파일에 기록
        ws['D4'] = json_data['ip']
        ws['E4'] = json_data['os_name']
        
        # 각 검사 결과를 엑셀 파일에 기록
        for i, data in enumerate(json_data['result']):
            ws[f'G{i+7}'] = ''
            ws[f'H{i+7}'] = ''

            if data['vuln'] == "Y":
                ws[f'F{i+7}'] = "양호"
            elif data['vuln'] == "N":
                ws[f'F{i+7}'] = "취약"
            else:
                ws[f'F{i+7}'] = "인터뷰"

            count = len(data['stdout'].split('\n'))
            for k, line in enumerate(data['stdout'].split('\n')):  # 표준 출력을 엑셀 파일에 기록
                if line == "Y" or line == "N" or line == "N/A":
                    continue

                if hangul_check(line):
                    if count-1 == k:
                        ws[f'G{i+7}'].value += line
                    else:
                        ws[f'G{i+7}'].value += line + '\n'
                else:
                    if count-1 == k:
                        ws[f'H{i+7}'].value += line
                    else:
                        ws[f'H{i+7}'].value += line + '\n'

            ws[f'H{i+7}'].value += '\n'
            ws[f'H{i+7}'].value += data['stderr']  # 표준 에러를 엑셀 파일에 기록

        wb.save(copied_excel_path)  # 엑셀 파일 저장
        wb.close()


def Main():
    print(f'*** start ***')

    # Ansible 설정 파일 생성
    print(f'*** create ansible.cfg file ***')
    create_ansible_cfg()

    # 인벤토리 파일 생성
    print(f'*** create invintory files ***')
    create_inventory()
    for i in os.listdir(local_inventory_dir):
        print(f'create inventory file : {i}')

    # 도커 이미지 체크 및 생성
    print(f'*** check docker image : {docker_image_tag} ***')
    if check_custom_docker_image(docker_image_tag):
        print(f'found docker iamge : {docker_image_tag}')
    else:
        print(f'not found. docker image.')
        create_custom_docker_image(docker_image_tag)

    # 컨테이너 실행
    print(f'*** run containers ansible ***')
    run_container(docker_image_tag)
    
    # 결과 JSON 파일 생성 확인
    for i in os.listdir(local_result_json_dir):
        print(f'create json file : {i}')

    # JSON 데이터를 엑셀 파일로 변환
    one_json_to_one_excel(load_json_files())

    # 결과 엑셀 파일 생성 확인
    for i in os.listdir(local_result_excel_dir):
        print(f'create excel file : {i}')

    print(f'*** end ***')


if __name__ == "__main__":
    Main()
