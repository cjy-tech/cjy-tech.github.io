## 작성 배경
스푼라디오 어플리케이션을 컨테이너화 하고 쿠버네티스 클러스터에 올리는 인프라 개선 작업을 진행하였습니다.  
IaC 도구인 terraform에 IAM user의 `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`를 제공하여 EKS를 생성하였습니다.  
해당 작업을 통해 정리한 아래와 같은 내용을 공유하기 위해 작성하였습니다.
- Terraform 모듈로 IAM role, vpc, subnet, 보안 그룹 및 EKS 클러스터 구성을 위한 작업 방법
- EC2 워커 노드에 SSM 접속을 위한 런치 템플릿 생성
- AWS 콘솔의 federated user 혹은 기타 AWS 리소스(ec2)의 IAM role로 `kubectl`을 사용하기 위한 `kubeconfig` 및 AWS profile 셋팅 방법

## 작업 내용

### EKS cluster 구성
1. EKS cluster에서 사용될 IAM role 생성
  - 이 role은 cluster의 control plane이 사용하는 것으로 계정별로 한개만 만들어도 무방할 것으로 생각했습니다.
  
2. 기존 퍼블릭, 프라이빗 subnet에 EKS cluster가 배치되도록 태그 작업
  - 스푼 라디오는 이미 잘 구성된 vpc, subnet 환경에 있습니다. 새롭게 네트워크를 만들기 보다는 [EKS docs에서 제공하는 클라우드 포메이션 yaml](https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml)을 참조하여 필요한 태그를 추가하는 작업을 진행했습니다.
  - 상기 yaml을 참조하면 아래와 같은 인터널 elb를 위한 태그, 퍼블릭 elb를 위한 태그를 알 수 있습니다.
  ![Screen Shot 2021-01-06 at 12 34 03 PM](https://user-images.githubusercontent.com/33619494/103726121-79a30d00-501b-11eb-95c0-3f9abe4eedc4.png)
  ![Screen Shot 2021-01-06 at 12 34 15 PM](https://user-images.githubusercontent.com/33619494/103726129-7e67c100-501b-11eb-9d4f-6a3fd8261516.png)
  - 해당 태그를 추가하기 위해 아래와 같이 terraform 값과 모듈을 사용하여 기존 subnet에 태그를 추가해 주었습니다.
  ![B0C204B6-D6DA-44DA-B653-95628A764EDE](https://user-images.githubusercontent.com/33619494/103743934-3909ba80-5040-11eb-9ebd-7bbbfb74dda2.png)
  - 실제 콘솔에서 조회해보면 subnet에 태그가 확인 됩니다.
  ![7B31F9A7-E794-4D43-8100-66BFAA7BD264](https://user-images.githubusercontent.com/33619494/103741718-eaa6ec80-503c-11eb-8d84-bbfc54d6c0bd.png)
  
3. 특정 cluster를 위한 개별 보안그룹도 생성 필요
  - 해당 보안 그룹은 클러스터마다 고유해야 한다고 권장합니다.
  ![Screen Shot 2020-12-17 at 6 39 35 PM](https://user-images.githubusercontent.com/33619494/102470365-3813e780-4097-11eb-8811-d18189b45fa0.png)
  - 인바운드는 없고 outbound는 all 인 보안 그룹을 생성하면 됩니다.
  
4. EKS cluster 생성
  ```yaml
  terraform {
    source = "스푼라디오 소스"
  }

  include {
    path = "${find_in_parent_folders()}"
  }

  inputs ={
    name                = "eks"
    kubernetes_version  = "1.18"

    # https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/network_reqs.html
    # subnet는 public subnet, private subnet를 모두 할당 해야 함.
    # 필요한 모든 서브넷 ID를 적어야 함.
    subnet_ids          = [
      "subnet-아이디1", "subnet-아이디2",
      "subnet-아이디3", "subnet-아이디4",
      "subnet-아이디5", "subnet-아이디6"
      ]

    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["특정 IP"]

    # ["api","audit","authenticator","controllerManager","scheduler"] 리스트 중 선택
    enabled_cluster_log_types     = []
    cluster_log_retention_period  = 0
  }
  ```
  - `subnet_ids`리스트에는 elb 태그가 달린 것 뿐 아니라 쿠버네티스 리소스가 배포되야 하는 모든 subnet 아이디를 추가해야 합니다.
  - 해당 subnet들은 `kubernetes.io/cluster/클러스터명`이라는 태그키와 `shared`라는 값을 가지게 됩니다.
  ![204B130F-9DF6-4132-AAA3-544932D4AFBF_4_5005_c](https://user-images.githubusercontent.com/33619494/103741920-4c675680-503d-11eb-8936-7383124ed6b9.jpeg)
  
5. `kubectl`을 사용하여 클러스터가 조회되는지 확인
  - `aws eks --region <리전명> update-kubeconfig --name <클러스터명>`
    - 이 명령은 기본적으로 홈 디렉토리의 `.kube` 디렉토리에 `config`파일을 만들고 그 내용을 업데이트 합니다.
    - 여러개의 클러스터를 등록할 수 록 해당 내용이 복잡해지고 원하는 클러스터 컨텍스트를 사용하기 어렵기 때문에 [kubectx, kubens](https://github.com/ahmetb/kubectx)라는 오픈 소스 사용을 하면 쿠버네티스 네임스페이스와 컨텍스트를 관리하기 편리합니다.
    - 또한 실험적으로 만들었던 클러스터 정보는 아래 명령어 3줄로 삭제할 수 있습니다.
    ```bash
    kubectl config unset users.<유저명>
    kubectl config unset contexts.<컨텍스트명>
    kubectl config unset clusters.<클러스터명>
    ```
  - Terraform을 사용하여 클러스터를 구성하였기 때문에 `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`의 값이 일치하여 로컬에서 `kubectl`명령을 바로 사용할 수 있게 됩니다.
    - 물론 로컬 환경의 `aws config`에 상기 `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`의 값이 존재해야 합니다.
  - `kubectl get svc`명령을 치면 아래와 비슷한 output이 나옵니다.
    ```bash
    NAME             TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
    svc/kubernetes   ClusterIP   10.100.0.1   <none>        443/TCP   1m
    ```

### 노드 그룹 생성
- 이제 클러스터 작동은 확인이 됐으니 쿠버네티스 Pod를 위한 워커 노드들을 추가해야 합니다.
- 프라이빗한 워커 노드에 접속하여 컨테이너 런타임 및 인프라 관련 사항을 확인 할 필요가 있었기에 세션 매니저 활성화가 필요했습니다.
- 기본적으로 노드 그룹을 생성하면 세션 매니저로 접속 할 수 없기 때문에 런치 템플릿을 이용하여 커스텀 한 노드를 만들었습니다.
- 이것 역시 terraform과 그 모듈을 이용하여 작업하였습니다.
1. 런치 템플릿
![Screen_Shot_2021-01-06_at_12_51_43_PM](https://user-images.githubusercontent.com/33619494/103727294-4615b200-501e-11eb-99e7-647265d060d9.jpeg)

2. 상기 런치 템플릿을 참조하는 노드 그룹 생성
![Screen_Shot_2021-01-06_at_12_57_55_PM](https://user-images.githubusercontent.com/33619494/103727582-f2f02f00-501e-11eb-923c-f91c19021208.jpeg)

- 실제 워커 노드에 들어가 쿠버네티스 관련 컨테이너 프로세스 등을 확인 할 수 있게 됐습니다.
![Screen Shot 2021-01-06 at 1 00 34 PM](https://user-images.githubusercontent.com/33619494/103727669-2cc13580-501f-11eb-9e4f-67d1b2e1d0d6.png)

- 또한 `kubectl get nodes`를 이용하여 생성된 워커 노드들이 조회됩니다.
![36960AD3-850B-4691-8354-B9E04D499CA3_4_5005_c](https://user-images.githubusercontent.com/33619494/103742110-a2d49500-503d-11eb-89f8-ce15a790a9d9.jpeg)

### IAM role 권한 부여
1. AWS 콘솔에서 쿠버네티스 리소스 관리 할 수 있도록 권한 부여
- EKS 클러스터는 기본적으로 생성한 IAM user 혹은 role에게만 마스터 노드와 통신할 수 있는 권한을 부여합니다.
- 때문에 `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`로 생성한 EKS 클러스터는 해당 키가 없으면 정보 조회가 불가능 합니다.
![Screen Shot 2021-01-06 at 4 42 11 PM](https://user-images.githubusercontent.com/33619494/103742423-22626400-503e-11eb-8751-4d847764b889.png)
- 저희는 AWS 콘솔을 사용 할 때 SAML 솔루션을 이용한 federated assume-role을 이용하기 때문에 해당 role을 `aws-auth`라는 쿠버네티스 configmap에 추가하였습니다(자세한 가이드는 [참고](https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting_iam.html#security-iam-troubleshoot-cannot-view-nodes-or-workloads)).
![Screen_Shot_2021-01-06_at_2_33_38_PM](https://user-images.githubusercontent.com/33619494/103733094-4321be00-502c-11eb-8157-84df29cef353.jpeg)
- 이후 정상적으로 AWS 콘솔에서도 쿠버네티스 클러스터 리소스를 확인 할 수 있었습니다.
![Pasted_Image_2021_01_06_2_28_PM](https://user-images.githubusercontent.com/33619494/103732797-8c254280-502b-11eb-9975-76e46fe025ed.jpeg)

2. [Spinnaker](https://spinnaker.io/)에서 쿠버네티스 마스터 노드와 통신 할 수 있는 권한 부여
- 인프라 개선 작업을 하면서 Spinnaker라는 배포 도구를 활용하여 쿠버네티스 리소스를 관리하기로 하였습니다.
- Spinnaker에서 저희가 구성한 EKS 클러스터 마스터 노드로 api 요청을 보낼 권한이 필요했습니다.
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`를 등록하면 편하지만 증설 시 키를 관리해줘야 하고, 프로비저닝 된 AMI 에 키 값을 넣는 것은 보안 상 너무 위험하기 때문에 aws profile과 assume-role을 조합하여 권한을 부여했습니다.
- 배포 구성도는 간략하게 아래와 같습니다.
![Infra2 0b - Copy of CI_CD Flow (1)](https://user-images.githubusercontent.com/33619494/103734688-df00f900-502f-11eb-93c3-457e1f72e721.jpeg)

2-1. 관리자 계정(이하 `AAAAA 계정`) spinnaker 서버의 IAM role에 서비스 계정(이하 `BBBBB 계정`) assume role 정책을 적용합니다.
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Resource": [
                "arn:aws:iam::<BBBBB 계정>:role/<BBBBB 계정 IAM role이름>"
            ],
            "Effect": "Allow"
        }
    ]
}
```

2-2. `BBBBB 계정` IAM role의 Trusted entities에 `AAAAA 계정` IAM role을 추가합니다.
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "1",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::<AAAAA 계정>:role/<AAAAA 계정 spinnaker 서버의 IAM role>"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

2-3. `AAAAA 계정` spinnaker 서버의 aws profile 업데이트
```bash
aws configure --profile <svc>
```
- 프롬프트로 발생하는 값 중 region 과 format만 입력하면 됩니다.
![94CC6D2D-C3D6-4099-B903-DF095F5FB3BE_4_5005_c](https://user-images.githubusercontent.com/33619494/103735497-8a5e7d80-5031-11eb-9386-57468e89a24e.jpeg)
- [aws 문서](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html)를 참고하여 `role_arn`과 `credential_source`를 추가해 줍니다.
```bash
[profile svc]
role_arn = arn:aws:iam::<BBBBB 계정>:role/<BBBBB 계정 IAM role이름>
credential_source = Ec2InstanceMetadata
region = us-east-1
output = json
```
- `credential_source`에 `Ec2InstanceMetadata`를 사용했기 때문에 `AAAAA 계정` spinnaker Amazon EC2 인스턴스에 연결된 IAM role을 사용하여 `BBBBB 계정` IAM role을 사용하는 자격을 가지게 됩니다.

2-4. kubeconfig 업데이트
- 2-3에서 설정한 AWS profile을 이용하여 `kubectl`명령을 사용하도록 kubeconfig를 수정합니다.
```bash
aws eks --region <us-east-1> --profile <svc> update-kubeconfig --name <eks클러스터이름>
```
- 상기 명령은 `kubectl`을 사용할 때 `svc`라는 AWS profile(2-3에서 설정한)을 이용한다는 뜻입니다.
- 실제 홈 디렉토리의 `.kube/config`파일을 살펴보면 `AWS_PROFILE`이라는 환경변수로 `svc`를 사용하는 것을 알 수 있습니다.
![Screen Shot 2021-01-06 at 3 28 59 PM](https://user-images.githubusercontent.com/33619494/103736600-e924f680-5033-11eb-9526-ad94bfb51ece.png)

2-5. 확인
- `kubectl get svc`명령을 치면 아래와 비슷한 output이 나오고 클러스터 마스터 노드와 통신이 가능하게 되었습니다.
```bash
NAME                     TYPE           CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)          AGE
kubernetes               ClusterIP      172.20.0.1      <none>                                                                    443/TCP          13d
```

## 작업 결과
- 저희의 목표인 `Spinnaker를 이용한 배포`의 기초가 완성됐습니다.
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`를 사용하지 않고 assumed-role로 접근 통제가 가능한 쿠버네티스 클러스터가 완성됐습니다.
![Infra2 0b - Copy of CI_CD Flow (1)](https://user-images.githubusercontent.com/33619494/103842810-044a4180-50da-11eb-96c5-5bbc7222fae8.jpeg)

## 느낀 점과 향후 계획
- 문서를 보면서 aws 콘솔에서 마우스질과 키보드질로 작업을 하나하나 해 나가야 하는 것보다 terraform으로 IaC를 하니 재사용 가능하여 생산성이 높아졌습니다.
  - 범용성을 가지고 확장 가능하게 terraform 모듈을 작업하는 게 중요하다고 느꼈습니다.
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`를 노출시키지 않고 assumed role과 aws profile을 이용해서 다른 계정, 다른 리전의 aws 리소스가 안전하게 `kubectl`을 사용하는 방법을 고민하는 좋은 시간이었습니다.
- Spinnaker - Jenkins - 쿠버네티스 클러스터로 이어지는 파이프라인 디자인이 필요합니다.
- 그를 위해 다양한 Spinnaker 플러그인과 셋팅법을 조사할 것입니다.
- 쿠버네티스 리소스를 helm 차트로 관리하기 위해 기존 yaml을 고도화 하고 차트와 밸류로 구분하여 작성할 것입니다.
- Spinnaker에서 helm 밸류 저장소와 연동 가능하도록 작업할 것입니다.
![Screen Shot 2021-01-06 at 4 46 15 PM](https://user-images.githubusercontent.com/33619494/103742769-b5030300-503e-11eb-910d-f78d3e02834d.png)
