---
layout: post
title: Terraform 설치 및 기본 정리
tags:
  - terraform
---

- Infrastructure as code(IaC)의 도구로 사용 할 수 있는 [Terraform](https://www.terraform.io/)에 대해 정리
- 설치 및 기초(?) 사용법을 적기로 한다.

### Terraform 설치
- [다운로드 페이지](https://www.terraform.io/downloads.html)에서 자신에게 맞는 OS를 선택하여 다운 받는다.
- 2019년 8월 16일 현재 가장 최신 버전은 0.12.6이다.
- 다운로드 받은 파일의 압축을 해제하면 `terraform` 바이너리가 하나 나온다.
- 해당 바이너리를 실행 가능한 `PATH`에 넣어주기만 하면 설치는 완료된다.

### Terraform Providers
- 기본적으로 terraform은 물리머신, vm, 컨테이너 등 인프라 리소스를 생성하기 위한 도구이다.
- 그 종류는 매우 많고 사용자가 원하는 provider를 선택하여 해당하는 리소스를 생성할 수 있다.
- 여기서는 aws provider를 이용해 aws 리소스 생성을 한다.
- 다른 provider들은 공식 레퍼런스 [참조](https://www.terraform.io/docs/providers/index.html)

### Terraform init
- Terraform은 `tf`라는 확장자를 가진 고유의 컨피그 언어를 사용한다.
- 이 `tf`파일을 읽고 `terraform`이 작업하기 위해 `init`과정이 필요하다.
- `terraform init`은 `tf`파일이 들어 있는 디렉토리를 새로 생성하거나, clone 했을 경우 실행해줘야 한다.
- `init`을 실행하면 디렉토리에 `.terraform`이라는 디렉토리가 생기는데 그 안에는 `tf`파일에 정의되어 있는 `provider`의 정보와 바이너리들이 있다.
- 더 자세한 사항은 공식 레퍼런스 [참조](https://www.terraform.io/docs/commands/init.html)

### Terraform 실행
- 설치와 init이 끝나면 teraform을 사용하기 위한 준비는 다 끝이 났다.
- 나머지는 `tf`파일을 문법에 맞게 작성하고 `plan`, `apply`, `destroy`를 실행하는 것이 거의 다이다.

#### Terraform plan
- `terraform plan`은 말 그대로 실행 계획을 보여준다.
- `tf`파일들에 정의된 상태에 맞게 생성될 리소스들을 보여주며, 정의되지 않은 리소스들은 기본 값을 가진다.
- `plan`을 실행해도 리소스의 변화는 없고 단지 `apply`하면 변화될 값을 보여준다.
![image](https://user-images.githubusercontent.com/33619494/63167597-b825d980-c06c-11e9-8b2b-5704ada0a3f7.png)
- 상기 이미지에서는 34개의 리소스가 생성되고 `tf`에 정의되지 않은 vpc의 arn 값 등은 적용 후 확인 할 수 있다고 나온다(`known after apply`).
- `plan`에는 `-out`이라는 옵션이 있는데 이것은 말 그대로 plan 해서 나온 결과를 특정 ZIP파일에 저장할 수 있는 것이다(`STDOUT`과 비슷하게 생각).
  - `terraform plan -out=$FILE_NAME`
- `-out`으로 나온 파일은 이후 `terraform apply`시 사용가능 하다.

#### Terraform apply
- `plan`으로 확인 한 결과를 적용하여 리소스 생성을 하기 위한 명령이다.
- `terraform apply`는 `tf`파일에 정의된 상태(desired state)를 보고 그에 맞게 리소스를 생성한다.
![image](https://user-images.githubusercontent.com/33619494/63170053-59b02980-c073-11e9-9aa5-266ee129927a.png)
- 상기와 같은 프롬프트가 나오면 `yes`를 입력하여 리소스 생성을 시작한다.
- `terraform plan -out`으로 나온 파일을 `apply`시 적용하기 위해서는 아래 명령어를 사용한다.
  - `terraform apply $FILE_NAME`
  
### 생성 결과
- 성공결과는 아래와 같은 메시지가 나오며 실제 aws 콘솔에서도 확인이 가능하다.
![image](https://user-images.githubusercontent.com/33619494/63170213-c7f4ec00-c073-11e9-8712-2565b031db82.png)
![image](https://user-images.githubusercontent.com/33619494/63170301-f4106d00-c073-11e9-859a-3f4953eb59d0.png)

### terraform.tfstate
- 리소스 생성 후, 디렉토리를 살펴보면 `terraform.tfstate`라는 JSON 형식의 파일이 있다.
- 해당 파일에는 생성한 인프라의 리소스 값이 들어가 있다.
- 보안 상 이 파일은 버전관리에서 무시하는게 좋고, 다른 원격지나 로컬 디스크에 저장하는 것이 좋다.

### 리소스 정리
- terraform으로 생성했으니 terraform으로 다시 리소스를 삭제 할 수 있다.
- `terraform destroy`명령을 실행한다.
- 마찬가지로 프롬프트에서 `yes`를 입력하여 리소스를 정리한다.

### 정리 결과
![image](https://user-images.githubusercontent.com/33619494/63170670-c4ae3000-c074-11e9-9704-c1f6cbe79b4f.png)
![image](https://user-images.githubusercontent.com/33619494/63170719-dabbf080-c074-11e9-829e-49b95ba07ff4.png)
