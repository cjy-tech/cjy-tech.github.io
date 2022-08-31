1. 애플리케이션 배포


Spinnaker의 강력한 기능 중 하나는 WEB UI를 통해 손쉽게 `Pipeline`을 구성할 수 있다는 것입니다. 배포단계의 workflow는 매우 다양하기 때문에 복잡한 workflow를 관리 할 수 있어야 합니다.
Spinnaker는 하나의 step을 `Stage`라는 용어로 정의하며 다양한 종류의 Stage를 지원하여 사용자가 원하는 Pipeline을 구성할 수 있도록 합니다.

Stage는 이전 Stage에서 파라미터를 전달받을 수 있고 다른 pipeline을 실행 할 수도 있습니다.

그리고 Spinnaker에서는 다양한 Pipeline 트리거 방법을 제공합니다.
대표적으로

jenkins
cron
git
webhook
docker registry의 신규 버전발견
다른 Pipeline
등에 의해서 실행될 수 있습니다.

이밖에 concourse, travis, wercker 과 같은 다른 플랫폼을 통해서도 실행 가능합니다.

이제 Pipeline을 구성하는데 있어 주요한 `Stage` 종류를 살펴 보겠습니다.
- Bake: VM 이미지를 생성합니다
- Check Precondition: 리소스가 특정 조건을 만족하는지 확인하여 다음 단계로 진행합니다. (Cluster의 사이즈 체크 등)
-Deploy: VM Image 또는 container를 배포합니다. red/black 또는 Highlander 배포 전략을 기본적으로 제공합니다. (canary 배포는 별도의 stage로 제공합니다)
- Jenkins: jenkins Job을 실행합니다.
- Manual Judgment: 사용자의 입력을 받아 진행 또는 중지를 선택할 수 있습니다.
- Pipeline: 다른 파이프라인을 실행합니다.
- Webhook: 다른 시스템의 Http Request를 호출합니다.
- ServerGroup/Cluster에 대해 활성/비활성/롤백/scale up(down) stage
Spinnaker에서 배포 방법은 기본적으로 Red/Black(Green/Blue) 배포와 전통적인 Highlander 방식을 모두 지원하며 안전한 배포를 위한 점진적 배포인 Canary 배포에 대해 지원하고 있습니다.
Canary 배포를 위해서 별도의 모니터링 툴이 필요하며 대표적으로 prometheus를 사용합니다

2. 애플리케이션 관리

Spinnaker는 Spinnaker를 통해 생성된 클라우드 리소스를 확인/관리 할 수 있습니다.
현대의 많은 서비스는 작은 서비스 단위의 모음인 MSA 구조로 개발되고 있으며, Spinnaker는 이 개념에 기반하여 리소스들을 관리 합니다.

`애플리케이션, 클러스터, 서버그룹`은 Spinnaker에서 가장 핵심적인 개념이며 리소스를 그룹화 관리하는 방법입니다.
또한 `로드밸런서(Load balancer)`와 `방화벽(firewall)`은 사용자에게 어떻게 노출될 것인지에 대해 관여 합니다.
![image](https://user-images.githubusercontent.com/33619494/187613257-acc48c1d-113c-424d-9928-b20d5ef30c3a.png)



### Application
클러스터의 논리적 그룹으로, 클러스터, 서버그룹, 방화벽, 로드밸런서를 포함하는 단위입니다. 서비스에 따라서 하나의 큰 서비스 자체로 맵핑 될 수 있고 또는 MSA의 하나의 component로 맵핑 될 수 있습니다.
배포 파이프라인(워크플로우)이 포함됩니다.
### Cluster
서버그룹의 논리적인 그룹으로 서버그룹의 묶음입니다.
참고로 kubernetes의 클러스터를 지칭하지 않습니다
### Server Group
VM 인스턴스들(EC2의 vm, Kubernetes의 Pod)의 그룹입니다.
하나의 서버그룹에 하나의 리소스 배포할 수 있고, 이것은 하나의 서버그룹은 동일기능을 한다고 말할 수 있습니다.
### Load balancer
서버그룹으로 유입되는 트래픽의 집입점에 대한 설정을 다룹니다.
서버그룹 내 또는 서버그룹들 간의 트래픽을 분산시키는 기능을 합니다.
### Firewall
ip와 port, protocol 을 이용해 Network 트래픽 접근을 제어합니다.
![image](https://user-images.githubusercontent.com/33619494/187613369-cd6854a6-414e-4c74-9089-50505c3ac6c1.png)






예를 들어 'TOAST콘솔' 이라는 프로젝트가 존재한다고 하겠습니다.
모바일 Web의 인증을 담당하는 동일한 VM들이 있고 이를 묶어서 `Server Group`이라 정의합니다.
그리고 인증을 담당하는 서버그룹의 V2 버전, V3 버전의 그룹이 존재할 수 있으며 이는 RED/BLACK 배포 또는 Canary 배포를 위해 필요한, 버전이 다른 서버그룹 입니다.
이 `Server Group`들을 묶어서 `Cluster` 라 정의 합니다. 하나의 `Application` 을 위해 여러 클러스터가 존재할 수 있습니다.

이러한 자료구조 외에, 만약 AWS처럼 region개념을 지원한다면
![image](https://user-images.githubusercontent.com/33619494/187613499-62f1afa4-4d18-4c84-b62f-f85f701ec7f8.png)


클러스터내에 us-east1, asia-northeast-1처럼 Region 으로 묶는 방법 역시 제공 하고 있습니다.

Application은 Cluster의 집합이고, Project는 Application의 집합입니다.
개발하고 배포하고자 하는 시스템의 구조에 따라서 Project, Application, Cluster와 Server Group 을 정의 할 수 있으며, 배포 전략과 Workflow 에 대한 고민이 필요합니다.
여기까지 기본적인 spinnaker 의 소개와 컨셉에 대해 알아봤습니다.
다음 글에서는 spinnaker의 설치법과 사용법에 대해 알아보도록 하겠습니다.

