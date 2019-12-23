# 마이쿤에서 DevOps로 살아남기
## 입사 전
- Terraform, CloudFormation, Ansible
- 뭔지 알겠고 대충 어떻게 쓰면 간단하게 인프라를 구성해주는 툴들이구나 하는 느낌

## 마이쿤 입사 과제 진행하며
- Terraform module이 뭐지?
- 계속해서 코드를 반복해서 사용하기 불편하네?
- Ansible이 원래 이렇게 어려웠나?

## 마이쿤 입사 후
- 지금까지 내가 알던 IaC는 빙산의 일각도 안된다.
- 앞으로도 배우고 익혀야 할게 많구나.

## 3개월간의 기록
### Terraform과 Terragrunt
- 마이쿤의 모든 인프라 환경은 AWS 환경에 구축되어 있다.
- 대부분의 사용자들이 간단하게 콘솔을 통해 환경을 구축한다.
- 이 경우, 여러 인프라 환경을 계속해서 만들때 반복적인 작업을 해야하는 단점이 있다.
- Terraform을 사용하면 생성하고자 하는 인프라를 코드로 정의하여 여러번 재활용 가능한 장점이 있다.
- 또한 terraform module을 사용하면 코드의 반복도 어느정도 줄일 수 있다.
- 리소스를 정의하고, 그 리소스를 반복적으로 사용하는 모듈을 각각 생성해주면 된다.

> 리소스

```terraform
resource "aws_cloudfront_distribution" "default" {
gg
  
  enabled             = "${var.enabled}"
  is_ipv6_enabled     = "${var.is_ipv6_enabled}"  
  price_class         = "${var.price_class}"
}
```

> 리소스를 사용하는 모듈1

```terraform
module "$모듈1" {
  source     = "$소스참조"
  enabled                           = "${var.enabled}"
  is_ipv6_enabled                   = "${var.is_ipv6_enabled}"
  price_class                       = "${var.price_class}"
}
```

- Terragrunt는 terraform의 remote state파일 활용을 도와주는 오픈 소스이다.

### Jenkins
- Jenkins 아이템을 구성 하는 것 역시 UI를 이용하는 것이 아닌 `Jenkinsfile`을 이용한다.
- `Jenkinsfile`을 이용하면 UI에서 만드는 것에 비해 버전기록을 남길 수 있다는 장점이 있다.
- 또한 jenkins의 콘솔 ouput log가 상당히 보기 불편한데 [blueocean](https://jenkins.io/doc/book/blueocean/)이라는 툴을 이용해 가시성을 높인다.

### Ansible과 AWX
- 처음 AWX를 들었을 때는 AWS 서비스를 잘 못 들은 줄 알았다.
- AWX는 ansible의 UI 버전으로 레드햇에서 제공하는 유료 솔루션인 ansible tower의 오픈 소스 버전이다.
- Ansible을 cli로만 사용하는 것이 아니고 UI를 사용하여 좀 더 직관적인 업무 환경을 제공한다.
- AWX에 ansible playbook 및 template 등을 등록해야 하는데 이 것은 `python`코드를 짜서 해결하였다.(개인적으로 해보고 싶은 작업)

### Docker와 docker-compose
- 상기한 환경을 구성하기 위하여, aws instance 위에 docker를 사용한다.
- Docker를 사용하면 이미 구성된 이미지를 가지고 어느 곳에서든지 재활용이 가능하기 때문에 작업자가 로컬에도 동일한 작업환경을 구축 할 수 있다는 장점이 있다.

### Vault
- 인프라를 구성하고 그 위에서 돌아가는 서비스들의 config를 조절 할 때, 일일히 변수값을 입력하는 대신 `vault`라는 변수 관리 시스템을 이용한다.
- 이 경우, 비밀 토큰 값 등 민감한 정보를 안전하게 보관하고 필요할 경우에만 그 값을 꺼내 쓸 수 있기 때문에 보안과 관리측면에서 굉장히 편리하다.

### 그 외
- DB를 관리하기 위한 `tadpole`
- DB 마이그레이션을 위한 `python` 코드
- 서버리스 프레임워크를 이용한 클라우드 포메이션 스택 생성과 람다 배포
- 그라파나, sentry, kibana 등 다양한 로그 및 모니터링 시스템

## 아쉬웠던 점
- 코드로 인프라를 구성할 때 계속해서 변화하는 시스템에 적응해야 했다.
- 실제 코딩으로 뭔가를 구성해 보고 싶은데 아직 그 수준에 이르지 못했다.
- 모니터링 및 서버리스 부분은 아직 많이 다뤄보지 못해 접근이 어려운 감이 있다.
