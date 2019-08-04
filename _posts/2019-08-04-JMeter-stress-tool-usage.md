---
layout: post
title: JMeter 이용한 AWS ALB 부하 테스트
tags:
  - JMeter
---

AWS ALB를 구성해 Private 인스턴스의 Nginx web 서버를 이중화 하였다.  
실제로 클라이언트가 2곳으로 분산돼 접속하는지 JMeter를 통해 HTTP Request를 보내고 Response를 확인해 본 기록을 남긴다.

### JMeter 설치
- Apache JMeter [홈페이지](https://jmeter.apache.org/download_jmeter.cgi)에 접속하여 원하는 바이너리를 다운받는다.
- 나의 경우 `zip`파일을 다운 받았다.
- 압축 해제하면 `apache-jmeter-$VERSION`이라는 디렉토리가 생성되고 그 안의 `bin`디렉토리의 `jmeter`를 실행하면 된다.
- 현재 최신 버전은 5.1.1이다.

### Java 8 버전 이상 설치
- `jmeter`를 실행해도 정상작동하지 않는데, 자바 8버전 이상이 깔려있지 않기 때문이다.
- Ubuntu 에서 `apt`로 설치한다.
```
sudo apt install openjdk-8-jre-headless -y
```
- 설치 완료 하면 `/usr/lib/jvm/java-8-openjdk-amd64` 경로가 생성된다.
- 해당 경로를 `JAVA_HOME`으로 환경변수에 export 한다.
```
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
```
- 다시 `jmeter`를 실행하면 정상 작동 한다.

### 테스트 진행
- 쓰레드 그룹 설정
![image](https://user-images.githubusercontent.com/33619494/62418931-33bc7980-b6b0-11e9-9f0c-5acfc200d90d.png)
- HTTP GET 할 ALB 주소와 80포트 설정
![image](https://user-images.githubusercontent.com/33619494/62418938-52227500-b6b0-11e9-97ba-6ce75841a251.png)
- 정상 응답 확인
  - 웹서버 1
  ![image](https://user-images.githubusercontent.com/33619494/62418943-69616280-b6b0-11e9-962a-1301b360b3e0.png)
  - 웹서버 2
  ![image](https://user-images.githubusercontent.com/33619494/62418944-6e261680-b6b0-11e9-8b9e-a77a265d0295.png)
- 실제 AWS CloudWatch에도 요청갯수가 증가한 것이 확인된다.
![image](https://user-images.githubusercontent.com/33619494/62418968-08865a00-b6b1-11e9-804e-17ae34666f10.png)
