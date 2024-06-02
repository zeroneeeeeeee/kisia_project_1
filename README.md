kisia project
주제 : 리눅스 CCE 스크립트 개발 및 자동 배포 도구 개발
기간 : 2024.03 ~ 2024.05
멘토님 : 토스 이종호 리더님
멘토원 : 이영원, 장한나, 이현석, 임찬미, 전호연
사용 기술 스택 : python, shell script, docker, ansible

방향성 / 취지 : 서버 취약점 진단 시 많은 서버를 관리 및 진단하기 위해선 자동화가 필수 입니다. 
현업에서 많은 서버를 관리하기 위한 방법 및 절차, 프로세스를 고민해보았습니다.
에스에스알의 SolidStep 제품을 모티브 삼아 online상 agentless 형식의 일관성있고 자동화된 배포 도구를 개발하기로 하였습니다.
특정 상황을 가정하여 시나리오를 구상하고 이에 따른 자동화 배포를 계획하였습니다.

멘토님 요구사항
- LLM(Chat Gpt)을 많이 활용해 볼것
- 프로젝트 작업의 과정과 시나리오에 대한 이해
- 도구 만드는 것은 중요하지 않음

역할
- 이영원 : 배포 서버 구축, 자동화 도구 개발 및 CCE shell script 개발 지원
- 장한나 : CCE shell script 개발 (u-19 ~ u-36)
- 이현석 : CCE shell script 개발 (u-37 ~ u-54)
- 임찬미 : CCE shell script 개발 (u-55 ~ u-72)
- 전호연 : CCE shell script 개발 (u-1 ~ u-18)

기술 스택 사용 이유
- python : 자동화를 위한 일련의 과정이 python 스크립트를 통해 가능하며, 가장 자신있는 언어이기에 선택했습니다.
- shell script : 서버 취약점 진단 시 최대한 많은 호환 및 적용 범위를 위해 shell script를 사용했습니다.
- docker : 프로젝트 시 운영 서버 배포 및 재사용에 용이하며 추후 쿠버네티스 활용을 위해 사용했습니다.
- ansible : 현업에서 많이 사용하는 도구중 agentless로 동작하기에 사용했습니다.

시나리오
- server_info.xlsx 파일에 서버 버전(ubuntu, centos), ssh user id, ssh password, ssh port, ssh private key file name, ssh sudo password란 내용을 입력해줍니다.
- ssh version, ssh user id, ssh port, ssh sudo password는 필수 입력 값 입니다.
- ssh password나 개인키 로그인 시 개인키 파일 이름을 엑셀에 적고 추후 운영서버 특정 디렉터리(private.d)에 ssh key를 넣어줍니다.
- server_info.xlsx의 입력 값이 문제 없고 개인키 지정 시 개인키가 특정 디렉터리(private.d)에 존재해야 하며, python start.py 실행 시 server_info.xlsx 파일을 읽고 ansible inventory book 생성 및 컨테이너에 바인드 마운트 하여 컨테이너 내부에서 inventory book이 전달됩니다.
- server_info.xlsx에 서버정보가 100개가 있다면 inventory book은 20개씩 생성되며 1개당 5개의 서버 정보가 존재합니다.
- 컨테이너 내부 ansible 실행 후 서버 하나당 json 파일이 하나 생성이 되며 해당 파일은 파싱을 통해 xlsx 파일로 변환됩니다.
- inventory book이 20개면 컨테이너는 20개씩 생성 및 삭제가 되며, 현재는 python container list을 통해 container object가 2개일 경우 더이상 생성하지 않도록 되어있습니다.

힘든점

아쉬운점

느낀점 / 마무리
