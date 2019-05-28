---
layout: post
title: Docker-compose를 이용한 GitLab 설치
tags:
  - docker-compose
  - gitlab
---

### GitLab이란 무엇인가?
![image](https://user-images.githubusercontent.com/33619494/48545469-52ec5e80-e909-11e8-9967-bf210ebd0310.png)
- GitLab에서 소개하는 문구로는 "전체 DevOps 수명주기를 관리 할 수 있는 하나의 어플리케이션"이다.
- 한 마디로 관리, 기획, 개발, 인증, 패키징, 릴리즈, 환경 셋팅, 모니터링, 보안까지 다 된다는 것이다(물론 유료로 구매하면).

### GitLab 설치
- GitLab에서는 Omnibus package(Ubuntu, CentOS 등)상에 설치하는 것을 추천하지만, 그 외의 방법으로도 설치 가능하다
- 여기서는 Docker-compose를 이용한 Official GitLab Docker 이미지로 GitLab 서버 설치를 소개한다.
- 선행조건
  - Docker-compose 설치
- `docker-compose.yml`파일을 아래와 같이 작성한다.
```yml
web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.example.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'https://gitlab.example.com'
  ports:
    - '80:80'
    - '443:443'
    - '22:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'
```
- `docker-compose up -d` 명령을 입력하여 GitLab 컨테이너를 실행한다.
- 상기 명령은 "GitLab CE" 이미지가 없다면 다운로드 하고, 컨테이너를 생성한다.
- `GITLAB_OMNIBUS_CONFIG` 환경변수를 이용해 도커 이미지를 미리 설정 할 수 있다.
- `gitlab.rb`파일이 존재하더라도 상기 환경변수로 설정 된 것이 먼저 적용된다.
- SSH, HTTP 및 HTTPS 프로토콜 사용을 위해 포트도 설정된다.
- 모든 GitLab 데이터는 호스트의 `/srv/gitlab/`디렉토리 밑에 저장된다.

| 호스트 위치   |      컨테이너 위치      |  용도 |
|----------|:-------------:|------:|
| /srv/gitlab/data |  /var/opt/gitlab  | For storing application data |
| /srv/gitlab/logs |  /var/log/gitlab  | For storing logs |
| /srv/gitlab/config |  /etc/gitlab  | For storing the GitLab configuration files |

- `/etc/gitlab/gitlab.rb` 파일에는 `GITLAB_OMNIBUS_CONFIG` 환경변수로 준 값들은 저장되지 않는다!
- [기타 환경 변수](https://docs.gitlab.com/ce/administration/environment_variables.html)는 링크를 참고

### 설치 확인
- 인터넷 브라우저를 실행하여 https://gitlab.example.com 로 접속하니 아래와 같이 확인이 된다!
![image](https://user-images.githubusercontent.com/33619494/58448333-89215b00-8142-11e9-8bc0-ee933847d6c6.png)


