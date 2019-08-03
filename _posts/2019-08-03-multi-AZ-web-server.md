---
layout: post
title: AWS 고가용성 Web 구축
tags:
  - aws
---

AWS를 이용한 Private 멀티 AZ에 존재하는 Nginx web 서버 구성에 대한 정리이다.

### 조건
#### 네트워크
- VPC의 경우 172.31.0.0/16 CIDR 제공되는 것을 사용한다.
- Public 2개, Private 2개로 총 4개의 서브넷을 구성한다.
- Public 서브넷에 NAT 게이트웨이를 1개씩 생성한다.
- Private 서브넷을 위한 라우팅 테이블을 각각 만들고 각각의 NAT 게이트웨이를 연결한다.
- Private 인스턴스를 각각 서브넷에 실행한다.
- Public 서브넷에 Bastion host를 두어 Private 인스턴스에 22번 포트로 접근가능하게 한다.
#### Web 서버
- Private 서브넷에 Nginx web server를 설치하고 가동시킨다.
- ALB를 생성하여 각 Private 인스턴스로 접근가능한지 확인한다.
- 한 서버를 다운 시켜도 ALB를 통한 접근은 계속 가능해야 한다.

### Subnet 구성
![image](https://user-images.githubusercontent.com/33619494/62409021-31084880-b60c-11e9-9475-ae28f6872016.png)
- 멀티 AZ를 위해 서울리전의 a,c zone에 각각 서브넷을 생성한다.
- 조건에 일치하도록 Public 2개, Private 2개를 생성하고 이름으로 구분한다.

### 라우팅 테이블 생성
- Private 서브넷이라 명명하였지만 연결된 라우팅 테이블이 인터넷 게이트웨이(igw)로 통하기 때문에 Public한 접근이 가능하다.
- igw가 없는 라우팅 테이블을 생성
![image](https://user-images.githubusercontent.com/33619494/62409088-387c2180-b60d-11e9-8e25-a681daa6f54b.png)

- Private 서브넷에 연결
![image](https://user-images.githubusercontent.com/33619494/62409100-7a0ccc80-b60d-11e9-9620-04ef94e868a8.png)

### NAT 게이트웨이 생성
- Private 서브넷에 Nginx web server를 설치하기 위해서는 인터넷 연결이 필요하다.
- 인터넷에서는 Private 인스턴스와의 연결을 막아야 한다.
- NAT 게이트웨이 서비스를 이용한다.
![image](https://user-images.githubusercontent.com/33619494/62409051-bbe94300-b60c-11e9-89fe-5b0a2f9352a1.png)

### NAT 게이트웨이, 라우팅 테이블 연결
- 생성한 NAT 게이트웨이를 라우팅 테이블에 연결해준다.
![image](https://user-images.githubusercontent.com/33619494/62409281-a590b680-b60f-11e9-8803-74cc517d0050.png)

![image](https://user-images.githubusercontent.com/33619494/62409298-c9ec9300-b60f-11e9-8fc8-b401a626a1d7.png)

### Private 인스턴스 생성
- 인스턴스를 생성하고 Private 서브넷에 위치하도록 한다.
![image](https://user-images.githubusercontent.com/33619494/62409384-45027900-b611-11e9-84a9-10f6496713aa.png)

- 보안 그룹은 default를 사용했다.
- 키 페어가 없으면 새롭게 생성하고 해당 `pem`파일은 보관에 유의한다.
- 생성이 완료되면 아래와 같이 퍼블릭 주소가 없는 인스턴스가 생성된다.
![image](https://user-images.githubusercontent.com/33619494/62409366-fead1a00-b610-11e9-80a7-f22017984fe8.png)
- c존의 서브넷에도 동일한 인스턴스를 생성한다.

### Bastion host 구성
- Public 서브넷에 인스턴스를 생성하고 엘라스틱 IP를 할당하여 외부에서 접속이 가능하도록 한다.
- 보안상 Bastion host는 특정 IP만 접근하도록 한다.
![image](https://user-images.githubusercontent.com/33619494/62409745-ffe14580-b616-11e9-9c1f-14cc2a4c5f60.png)

- pem키를 이용하여 접속 완료
![image](https://user-images.githubusercontent.com/33619494/62409789-77af7000-b617-11e9-968a-0ff15b02b72b.png)

### Nginx 설치 및 가동
- Public 서브넷의 Bastion host를 통해 Private 인스턴스에 접속해 작업을 진행하도록 한다.
- Bastion host에서 다시 pem키를 이용해 각각의 Private 인스턴스로 접속한다.
- Nginx 설치 및 가동
```
sudo amazon-linux-extras install nginx1.12 -y
sudo service nginx start
```

### ALB 생성
- 각각의 Private 인스턴스에서 가동중인 Nginx를 브라우저로 확인하기 위해 ALB를 생성하고 그 DNS로 접근해본다.
- 접속 완료
![image](https://user-images.githubusercontent.com/33619494/62410013-c90d2e80-b61a-11e9-8d69-36baa1bc86eb.png)

### 검증방법
- 한쪽의 Nginx를 다운시켜도 계속해서 접속이 가능해야 한다.
- a존의 Nginx를 다운시키고 다시 들어가본다.
`sudo service nginx start`
![image](https://user-images.githubusercontent.com/33619494/62410002-ad098d00-b61a-11e9-8172-628a23081415.png)
- 웹서버 2로 잘 들어가고 있다.
