FROM ubuntu:latest
    
RUN apt update && apt install -y software-properties-common && add-apt-repository --yes --update ppa:ansible/ansible && apt install -y ansible
    
RUN mkdir -p /root/miniproject/inventory.d
RUN mkdir /root/miniproject/privatekey.d
RUN mkdir /root/miniproject/result.d
RUN mkdir /root/miniproject/script.d

COPY ./script.d/ /root/miniproject/script.d/
COPY ./yml.d/mainBook.yml /root/miniproject/mainBook.yml
COPY ./yml.d/taskBook.yml /root/miniproject/taskBook.yml
COPY ./ansible.cfg /root/miniproject/ansible.cfg

WORKDIR /root/miniproject
