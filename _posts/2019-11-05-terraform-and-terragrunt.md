# Terraform

## Basic

### 장점

- 인프라를 코드로 관리하여 재사용이 가능
- `default` 값에 영향 받지 않는 이상 멱등성 확보
- `plan` 을 통해서 변경 사항 확인 가능
- `*.tfstate` 파일을 이용해 상태 비교

### 단점

- 동일한 환경을 구성하면 중복 되지 않은 코드를 작성하기가 어려움
- 버전이 다르면 `hcl` 언어의 문법이 달라질 수 있음

### 정리

- 실무에서 사용하기 위해서는 마이크로 단위로 모듈화
- 모듈에 맞는 변수들만 바꿔서 다양한 인프라스트럭쳐를 구성하는데 활용

## Module

### 개요

- 코드 작성 시 반복되는 기능을 함수로 구현 하는 것처럼 재사용 되는 리소스를 모듈로 묶는 것
- `*.tf` 파일에서 불러오기 위해서는 `source` 라는 지시어를 사용

```
provider "aws" {
  region = "us-east-2"
}
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"
}
## webserver_cluster 모듈에 정보가 기록되어 있고 추가적인 정보는 provider 하나이다.
## 다른 리전에 배포하기 위해서는 provider 값만 바꿔주면 된다.
```

## tfstate

### 개요

- 테라폼으로 `apply` 하여 나온 인프라의 결과 상태가 기록되는 파일이다.
- 이후 테라폼 설정을 변경하여 다시 `apply` 하면 이 `tfstate` 파일을 확인하여 달라진점을 실제 적용한다.
- 민감한 정보가 담겨 있기도 하므로 원격으로 관리하는 것이 좋고
- 결정적으로 협업 할 경우 여러 사람이 하나의 `tfstate`파일을 가지고 있는 테라폼 소스를 수정하게 되면 충돌이 일어나므로
- `remote state` 를 사용하여 아마존 s3에 `tfstate` 를 저장할 수 있다.
- 또한 Lock 기능을 제공해 협업 시 리소스 형상의 충돌을 방지한다.

```
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "stage/frontend-app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "my-lock-table"
  }
}
```



# Terragrunt

## 사용 이유

- module화를 진행하더라도 남아 있는 중복 코드 때문
- remote state의 `key`값을 테라폼 디렉토리와 동일하게 자동 생성
- tfstate를 remote로 관리하게 되면 모듈파일에 `backend`설정을 전부 다 넣어줘야함
- `terraform apply` 시 추가적으로 사용하는 `var-file` 미리 정의하여 사용 가능

### 적용 사례 1

- 테라폼 루트 디렉토리에 `backend` 설정을 아래와 같이 작성

  ```
  remote_state {
          backend = "s3"
  
          config {
              encrypt         = true
              bucket          = "$S3버킷명"
              key             = "stg/${path_relative_to_include()}/terraform.tfstate"
              region          = "$aw리전"
              dynamodb_table  = "stg-mgt-terraform-dynamodb"
              profile         = "Spoon_MGT"
          }
      }
  ```

  - `path_relative_to_include()`함수는 리모트 저장소에 현재 프로젝트 디렉토리에 따른 폴더를 생성해준다.

  - 각각의 테라폼 모듈 파일의 `backend`설정을 아래와 같이 작성

    ```
    terraform {
      # Intentionally empty. Will be filled by Terragrunt.
      backend "s3" {}
    }
    ```

  - 테라폼 변수값이 들어있는 `tf`파일에서 `remote_state`를 상속받을 수 있도록 아래와 같이 작성

    ```
    include {
      path = find_in_parent_folders()
    }
    ```

  ### 적용 사례 2

  - `terraform apply`시 추가적인 파라미터를 주기 위해서는 매번 `-var-file`을 입력해야 하나 아래와 같이 미리 정의하면 매번 자동으로 적용됨

    ```
    terraform {
      extra_arguments "common_vars" {
        commands = get_terraform_commands_that_need_vars()
    
        arguments = [
          "-var-file=../../common.tfvars",
          "-var-file=../region.tfvars"
        ]
      }
    }
    ```

  - `get_terraform_commands_that_need_vars()` 함수를 이용해 `-var-file`을 파라미터로 사용하는 모든 테라폼 명령들을 알아서 인지하고 적용해준다.
