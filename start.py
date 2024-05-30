# pip install docker
# pip install pandas
# pip install openpyxl
# pip install configparser


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

current_directory = os.getcwd() # /home/ansibleuser/miniproject

local_inventory_dir = f"{current_directory}/inventory.d/"
local_private_key_dir = f"{current_directory}/privateKey.d/"
local_result_json_dir = f"{current_directory}/result_json.d/"
local_result_excel_dir = f"{current_directory}/result_excel.d/"

local_excel_file_path = f"{current_directory}/server_info.xlsx" # server info(user, password) list file
local_source_excel_path = f"{current_directory}/example_excel.d/example_1.xlsx"
local_ansible_cfg_path = f"{current_directory}/ansible.cfg"
local_dockerfile_path = f"{current_directory}/dockerfile"

container_result_dir = "/root/miniproject/result.d/"
container_inventory_dir = "/root/miniproject/inventory.d/"
container_private_key_dir = "/root/miniproject/privatekey.d/"

container_playbook_path = "/root/miniproject/mainBook.yml"


client = docker.from_env()


def create_ansible_cfg(forks=1):
    config = cp.ConfigParser(allow_no_value=True) # 섹션 밑에 옵션 없어도 허용
    config.add_section('defaults')

    config.set('defaults', "ask_pass = false") # 암호 요청 메시지 표시 여부
    config.set('defaults', "host_key_checking = false") # 사전 키교환 여부 무시
    config.set('defaults', f"forks={forks}") # 병렬 실행 수

    with open(local_ansible_cfg_path, "w") as configfile:
        config.write(configfile)

    print(f'create ansible.cfg file path : {local_ansible_cfg_path}')


def create_inventory(max_num=1):
    excel_column = ['os_name', 'ip', 'ssh_port', 'ssh_user_name', 'ssh_password', 'ssh_private_key_file_name','ssh_sudo_password']

    pd_data = pd.read_excel(local_excel_file_path) # type pandas.core.frame.dataFrame

    os_sections = pd_data[excel_column[0]].unique() # ['ubuntu' 'centos'] type numpy.ndarray

    max_hosts = max_num # 함수 인자값으로 받아서 변수에 넣기

    file_count = int(np.ceil(len(pd_data) / max_hosts))

    for i in range(file_count):
        config = cp.ConfigParser(allow_no_value=True) 

        start_index = i * max_hosts
        end_index = start_index + max_hosts
        subset = pd_data.iloc[start_index:end_index] # row number slicing

        for os_section in os_sections:
            hosts = subset[subset[excel_column[0]] == os_section]


            #print(hosts)
            #exit()
            if not hosts.empty:
                config.add_section(os_section)
                # index, row
                for _, row in hosts.iterrows(): # row : pandas.core.series.series

                    #print(row)
                    #exit()
                    host_line = f"{row[excel_column[1]]} ansible_host={row[excel_column[1]]} ansible_port={row[excel_column[2]]} ansible_user={row[excel_column[3]]} " # ip, ssh_host ssh port, ssh username
                    if pd.notna(row[excel_column[4]]): # ssh password check
                        host_line += f"ansible_ssh_pass={row['ssh_password']} "
                    if pd.notna(row[excel_column[5]]): # ssh private key file name check
                        host_line += f"ansible_ssh_private_key_file={container_private_key_dir}{row[excel_column[5]]} "

                    if pd.notna(row[excel_column[6]]): # ssh sudo password check
                        host_line += f"ansible_become=true ansible_sudo_pass={row[excel_column[6]]}"
                    config.set(os_section, host_line)

        with open(f"{local_inventory_dir}inventory_{i+1}.ini", "w") as configfile:
            config.write(configfile)


def check_custom_docker_image(docker_image_tag): # custom docker image check
    try:
        docker_image = client.images.get(docker_image_tag)
    except docker.errors.ImageNotFound:
        return False
    return docker_image


def create_custom_docker_image(docker_image_tag): #  custom docker image create
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

    with open(local_dockerfile_path, 'w') as f:
        f.write(dockerfile_content)
    print(f'success docker file path : {local_dockerfile_path}')

    #exit()
    print(f'create docker_image_tag : {docker_image_tag}')
    image, _ = client.images.build(
        path='.', # 현재 경로 / 상대 경로
        dockerfile='dockerfile',
        tag=docker_image_tag,
        rm=True,
        nocache=False
    )

    if docker_image_tag in image.tags[0]:
        print(f'success docker_image_tag : {docker_image_tag}')
    else:
        print(f'fail create docker image tag')
        print(f'end main')
        exit()


def run_container(image_tag, num_containers=2):
    volumes = { # bind mount
        local_result_json_dir: {'bind': container_result_dir, 'mode': 'rw'},
        local_inventory_dir: {'bind': container_inventory_dir, 'mode': 'rw'},
        local_private_key_dir: {'bind': container_private_key_dir, 'mode': 'ro'}
    }
    inventory_file_list = sorted([f for f in os.listdir(local_inventory_dir) if f.endswith('.ini')]) # get .ini file list 

    while True:
        container_val = len(client.containers.list('all'))

        if container_val == int(num_containers):
            time.sleep(5)
            continue

        if not inventory_file_list:
            if len(client.containers.list('all')) == 0:
                print(f'all containers exited')
                break

        if inventory_file_list:
            inv_file = inventory_file_list.pop(0)

            container = client.containers.run(
                image_tag,
                #command=f"/bin/bash",
                command=f"ansible-playbook mainBook.yml -i ./inventory.d/{inv_file}",
                detach=True, # background
                #stdin_open=True,
                #tty=True,
                volumes=volumes,
                auto_remove=True
                #auto_remove=False
            )

            #exit()
            print(f"Running container ID {container.short_id}")

        time.sleep(5)


def load_json_files(): # json file all read
    json_lists = []
    result_file_list = sorted([os.path.join(local_result_json_dir, f) for f in os.listdir(local_result_json_dir)])

    for filename in result_file_list:
        with open(filename, 'r', encoding='utf-8') as file:
            json_lists.append(json.load(file))

    return json_lists


def hangul_check(text):
    for chat in text:
        if '\uac00' <= chat <= '\ud7a3':
            return True
    return False


def one_json_to_one_excel(json_lists):
    
    for json_data in json_lists:
        copied_excel_path = f"{local_result_excel_dir}{json_data['ip']}_result.xlsx"

        shutil.copy(local_source_excel_path, copied_excel_path) # example xlsx hard copy

        time.sleep(1)

        wb = load_workbook(copied_excel_path)
        ws = wb.active

        ws['D4'] = json_data['ip']
        ws['E4'] = json_data['os_name']
        
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
            for k, line in enumerate(data['stdout'].split('\n')):
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
            ws[f'H{i+7}'].value += data['stderr']

        wb.save(copied_excel_path)
        wb.close()


def Main():
    print(f'*** start ***')

    print(f'*** create ansible.cfg file ***')
    create_ansible_cfg()

    #exit()
    print(f'*** create invintory files ***')
    create_inventory()
    for i in os.listdir(local_inventory_dir):
        print(f'create inventory file : {i}')

    #exit()
    print(f'*** check docker image : {docker_image_tag} ***')
    if check_custom_docker_image(docker_image_tag):
        print(f'found docker iamge : {docker_image_tag}')
    else:
        print(f'not found. docker image.')
        create_custom_docker_image(docker_image_tag)

    #exit()
    print(f'*** run containers ansible ***')
    run_container(docker_image_tag)
    
    for i in os.listdir(local_result_json_dir):
        print(f'create json file : {i}')

    #exit()
    one_json_to_one_excel(load_json_files())

    for i in os.listdir(local_result_excel_dir):
        print(f'create excel file : {i}')

    print(f'*** end ***')


if __name__ == "__main__":
    Main()