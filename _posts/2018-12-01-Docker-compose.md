---
layout: post
title: Docker Compose 소개
tags:
  - docker
  - docker-compose
---

### 개요
- docker 로 컨테이너를 띄우기 위해서는 `docker run 옵션`을 사용한다.
- 다수의 컨테이너를 매번 `docker run 옵션`으로 띄우는 것은 비효율 적이고, 컨테이너의 상황도 직접 확인해야 한다.
- 그것을 커버하기 위해 사용하는 것이 docker compose

### Docker Compose란?
- 다수의 컨테이너를 개별 서비스로 정의하여 컨테이너 묶음으로 관리할 수 있다.
- 컨테이너를 이용한 서비스 개발과 CI를 위하여 다수 컨테이너를 하나의 프로젝트로 다룰 수 있는 작업환경 제공한다.
- 다수 컨테이너의 옵션과 환경을 정의한 파일(`docker-compose.yml`)을 읽어 컨테이너를 순차적으로 생성하는 방식으로 동작한다.
```yml
version: '3'
# services 아래로 도커 컴포즈 프로세스를 정의
services:
  # web이라는 도커 컴포즈 프로세스의 스펙
  web:
    # docker repository에 있는 이미지
    image: 이미지 이름
    #노출 시킬 container 포트
    expose:
       - "80"
       - "443"
    #컨테이너 이름
    container_name: docker-test
    network_mode: bridge
    # 컨테이너 내의 환경변수
    environment:
      - _IS_TEST=TRUE
    #호스트 서버와 docker container 간의 볼륨공유
    volumes:
      - ./public_html:/var/www/html
```
- 상기 파일을 docker run으로 쓰면
```bash
docker run --expose 80 --expose 443 --name docker-test -network bridge -env _IS_TEST=TRUE -v /mnt/workspace/docker-test/public_html:/var/www/html 블라블라...
``` 
너무 길다..

### 정리
- Docker compose는 docker run 명령을 매번 치지 않아도 되는 효율성이 있다.
- 여러 서비스를 하는 컨테이너를 관리하기 편하다.
- 대신 하나의 컨테이너에 여러 args 때문에 불편할 경우 도커 컴포즈를 추가적으로 설치할 필요가 없으니 쉘 스크립트로 대체하자.
