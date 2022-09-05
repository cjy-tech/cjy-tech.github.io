현재 문서는 1.19.2 버전을 기준으로 작성되었습니다. spinnaker는 버전이 빠르게 바뀌고 있기 때문에 문서 내용이 추후 버전에는 맞지 않을 수 있으니 참고 부탁드립니다.

https://www.spinnaker.io/setup/quickstart/ 를 보시면 직접설치 하지 않고 cloud provider들이 제공하는 간단한 사용을 해 보실 수 있습니다. 간단한 테스트는 위의 링크에서 가이드를 따라가 보시는걸 추천드립니다.
하지만 production환경에서 이용하는것은 권장하지 않기 때문에 production에서 사용하기 위해서는 직접 설치하는것을 추천합니다.

이 문서에서 다룰 내용
이 글에서는 docker를 이용한 halyard 설치와 minikube 환경의 kubernetes를 이용한 spinnkaer 설치에 대한 가이드를 다룰 예정입니다.

진행 순서
Halyard 설치
Spinnaker를 설치할 CloudProvider 설정
AWS, GCP, Azure, kubernetes 등
설치 환경 설정
분산환경설치, 로컬 환경 설치, spinnaker 개발용 설치
스토리지 설정
S3, google storage, minio, redis 등
spinnaker 설치
web 화면 접근
이후 production 환경 사용을 위해 config 백업과 세밀한 설정 조정, 권한 관리 등의 고급설정이 있지만 여기에서는 다루지 않겠습니다.

그럼 시작해 보겠습니다.

설치환경전 필요한 것
Spinnaker 설치를 위해 필요한 것은 두 가지 입니다.

halyard(spinnaker 설치 cli)가 설치된 머신(mac or ubuntu, Docker)
spinnaker를 설치한 kuberneates 클러스터
harlyard란?
spinnaker를 설치하기 위해서 필요한 cli 도구입니다.
spinnaker는 11개의 마이크로서비스로 구성된 MSA 구조를 가졌습니다. 각 마이크로 서비스간 의존관계가 있기 때문에 직접 모든 마이크로 서비스를 설치하고 관리하는데 큰 어려움이 있습니다.
그래서 halyard라는 cli 관리 도구를 이용해 spinnaker를 설치하는데 필요한 설정 값과 환경등을 설정하고 Spinnaker를 설치할 수 있게 합니다.
halyard는 spinnaker 설치 이후, spinnaker의 버전 업데이트 또는 spinnaker에서 관리하는 사용자서비스 배포를 위한 cloud 정보와 repository, ci 정보 등을 관리합니다.

![image](https://user-images.githubusercontent.com/33619494/188168087-255b364d-b03b-4eff-ad34-94311b0cf926.png)

kuberneates
spinnaker 설치를 위해서는 spinnaker 자체가 설치 될 수 있는 kubernetes 환경이 필요 합니다.
WMI에 kubernetes를 직접 설치하고 그 위에 spinnaker를 설치하는것을 최종 목적으로 하지만, kubernetes에 대한 내용은 이 글의 목적과 맞지 않기 때문에 다루지 않겠습니다. kubernetes와 관련된 설치 및 소개 등은 다른 기술공유 글을 참고 부탁드립니다.

저희는 간단히 kubenetes환경을 데모할 수 있는 minikube를 설치하여 진행하겠습니다. 단, minikube 이용시 메모리를 12GB 이상을 할당해야 spinnaker가 정상적으로 동작하기 때문에, minikube가 설치된 머신은 최소 16GB 이상의 메모리를 권장합니다.
minikube 관련 설치는 여기 링크의 하단부분 실습환경(minikube) 부분을 참고하시면 됩니다.

minikube start
```bash
 minikube start --cpus 4 --memory 12288  --embed-certs
 ```

1. Halyard 설치
halyard 설치는 ubuntu linux 머신(centos는 안됩니다) 또는 mac, 그리고 docker를 이용해 설치가 가능합니다. 어떤 방식이든 편한 방법으로 하시면 됩니다.

linux나 mac에 설치하기 위해서는 인스톨러를 다운받아 실행하면 됩니다
*
docker에 설치 하실 분은 docker가 설치된 환경에서 아래 명령어를 실행하면 됩니다. 저는 docker 를 이용해 설치 했습니다.
docker 실행
```bash
mkdir ~/.hal
docker run -p 8084:8084 -p 9000:9000 \
    --name halyard --rm \
    -v ~/.hal:/home/spinnaker/.hal \
    -it \
    gcr.io/spinnaker-marketplace/halyard:stable
```
halyard container 접근

`docker exec -it halyard bash`


설치 확인
halyard가 설치된 환경에서 hal -v명령어를 입력하여 버전정보가 출력되면 정상적으로 설치된 것으로 볼 수 있습니다.
![image](https://user-images.githubusercontent.com/33619494/188168515-dc0fad00-ebfe-4009-a3ce-93c3ce198ef1.png)

(위의 이미지는 docker 환경에서 실행한 모습니다)

2. CloudProvider 설정
이제 본격적으로 hal 명령어를 이용해 Spinnaker 설치정보 설정을 해보겠습니다.
우리는 kubernetes 환경에 spinnaker를 설치할 것이기 때문에 kubernetes접근을 위한 준비가 필요합니다.

필요한 파일
kubeconfig 파일 - spinnaker/halyard가 kubernates 클러스터에 접근할 수 있는 권한을 얻기 위해 config에 설정된 인증서를 이용합니다.
kubectl CLI 툴 - kubernetes의 api를 사용하기 위해 필요한 cli파일입니다. halyard가 설치된 docker에 이미 설치되어 있으며, kubectl [명령어] 형식으로 이용합니다. (minikube가 설치된 local환경에도 kubectl이 존재합니다)
우선 halyard가 설치된 docker 컨테이너의 ~/.kube/config config 파일을 넣어야 합니다. kubeconfig 파일 내용을 보겠습니다.

```bash
kubectl config view
```
명령어를 이용하면 `~/.kube/config` 파일 내용을 보여줍니다.
![image](https://user-images.githubusercontent.com/33619494/188168756-f3832dc0-5547-4901-921e-2effa71b3229.png)

cluster 서버정보와 인증서, 그리고 사용자 키들이 보입니다. 이 파일을 그대로 mount한 폴더로 복사한다면, halyard에서는 설정된 절대경로에서 인증서와 키파일을 찾게 되고, 당연히 halyard 컨테이너에는 저 위치에 파일이 존재 하지 않습니다. 
때문에, config 파일에 cert의 데이타 자체를 포함 할 수 있게 파일을 만들어야 합니다

인증서를 포함한 config 파일 만드는 방법
minikube start 명령어 --embed-certs=true 옵션 사용
처음 minikube를 실행할때 이 옵션을 추가하면 config 파일내에 인증서와 키파일이 포함되어 ~/.kube/config 파일만 mount폴더로 복사하면 됩니다
minkube start시 minikube ca.crt파일을 찾을 수 없다는 메시지와 함께 실패하는 케이스가 있습니다. 이럴땐, 우선 embed-certs옵션 없이 minikube를 start하고 minikube stop 후 다시 --embed-certs=true 를 추가하여 start하면 됩니다
![image](https://user-images.githubusercontent.com/33619494/188168816-d59fd040-1032-429c-9987-c6237ac0a243.png)

2.1 cloudProvider 접근 정보 설정
halyard가 kubernetes에 접근이 가능하도록 파일이 준비 되었다면, 해당 정보를 이용할 수 있도록 halyard에 설정을 추가해야 합니다
halyard가 kubernetes로 접근하는 계정을 하나 설정하겠습니다.
아래 명령을 실행하면 halyard에 my-k8s-account라는 이름의 account가 생성됩니다
hal config provider kubernetes enable

CONTEXT=$(kubectl config current-context)

hal config provider kubernetes account add my-k8s-v2-account \
    --provider-version v2 \
    --context $CONTEXT
추가로 artifact 라는 feature를 enable해줘야 합니다. artifact는 spinnaker안에서 사용되는 용어로, 배포 또는 참조하는 리소를 가리키는 spec을 json 문자열로 만들어 놓은것을 의미합니다. 설치를 위해 설정해 주세요

hal config features edit --artifacts true
3. 설치 환경 설정
설치 환경은 세가지 환경이 존재합니다

분산환경설치, 로컬 환경 설치, spinnaker 개발용 설치
분산환경 설치: cloudprovider를 이용한 분산 설치 방법. spinnaker 업데이트 및 설정시 downtime이 없음
로컬 환경 설치: 모든 마이크로 서비스를 하나의 로컬환경에 설치 및 실행 하는 방법. halyard가 설치된 로컬에 모든 서비스를 다운로드 하여 실행하는 방법
개발용 설치: spinnaker를 개발 및 contribution하기 위한 설치 방법
우리는 위 방법중 kubernetes에 설치를 위한 분산환경 설치를 진행하겠습니다

hal config deploy edit --type distributed --account-name $ACCOUNT
4. 스토리지 설정
spinnaker가 사용할 persistence layer의 저장소를 지정합니다.
spinnaker에서 지원하는 저장소 목록은 아래와 같습니다.

Azure Storage
Google Cloud Storage
Minio
Redis
S3
Oracle Object Storage
사용하는 cloud provider 와 별도로 설정이 가능하며, 저희는 minio 서비스를 이용하도록 하겠습니다.
minio를 kubernetes 노트에서 접근 가능한 서버에 올리고 해당 서버의 접근 정보를 입력해 주겠습니다
(minio에 대한 자세한 소개와 사용법은 여기를 참고 부탁드립니다.)

주의: minio 설치 및 실행 시 등록한 secret이 필요하므로 실행시 꼭 secret을 지정하거나 실행시 생성되는 secret을 저장해 두시길 바랍니다.
4.1 minio 계정 설정
스크립트 실행으로 minio접근 권한을 설정합니다
storage type을 s3로 지정하는 이유는 minio가 s3 호환가능한 api를 제공하고, spinnaker에서는 s3 인터페이스를 이용해 minio에 접근하기 때문입니다.
아래 사용자키와 접근키는 minio 실행시 설정하므로 실행시 설정한 값을 참고해주세요
MINIO_SECRET_KEY=사용자키
ENDPOINT=MINIO접근주소
MINIO_ACCESS_KEY=접근키

echo $MINIO_SECRET_KEY | hal config storage s3 edit --endpoint $ENDPOINT \
    --access-key-id $MINIO_ACCESS_KEY \
    --secret-access-key 

hal config storage edit --type s3
추가
minio설치시 virtualhost path style을 지정하지 않았다면 아래 옵션을 지정해야합니다. url의 스타일에 대한 것으로 path style이 맞지 않을 경우 문제가 발생합니다.

config storage s3 edit --path-style-access true
5. Spinnaker 설치
5.1 버전 설정
서두에 말씀드렸듯이 빠르게 버전이 올라가고 있으며, 메이저 버전을 세분화하여 버전이 공개되어 있기 때문에 원하는 버전을 설치하면 됩니다. 하지만 저희는 이제 시작이기 때문에 공개된 stable 버전 중 최신 버전을 사용하겠습니다.

hal version list
커맨드를 이용하면 현재 메이저 버전들의 최신버전들이 리스트업 됩니다. 각 버전별로 연동되는 halyard 버전이 명시되어 있으니 이점 유의해서 사용해야 합니다. 지금 진행하는 halyard는 최신버전을 사용하기 때문에 어떤 버전을 쓰더라도 문제 없습니다.

저는 아래 커맨드로 가장 최신인 1.19.2 를 설정해둔 상태입니다.

hal config version edit --version 1.19.2

![image](https://user-images.githubusercontent.com/33619494/188168928-5cb50b21-e8f6-4ece-80fc-b84018bf5a38.png)

이 외의 사용가능 버전과 deprecated된 버전은 여기에서 확인 가능합니다.

5.2 설치 실행
이제 spinnaker 설치를 위한 설정이 끝났습니다.

hal deploy apply
를 입력하면 설치를 진행합니다

만약 설치 상태가 궁금하시면 kubernetes의 각 pod 들의 상태를 확인해 봅시다
(spinnaker의 default 네임스페이스는 spinnaker 입니다)

kubectl get pod -n spinnaker
![image](https://user-images.githubusercontent.com/33619494/188168971-e319eb75-3b0c-44b5-9606-b382d6fa3f25.png)

![image](https://user-images.githubusercontent.com/33619494/188169003-64182af1-d8df-4b34-af72-f408d1df1ea1.png)

(문서 작성중 시간의 흐름이 있어 시차가 생겼습니다. 또한 중간에 minio 서비스가 다운되어 persistence layer를 담당하는 pod의 restart 횟수가 147회나 되네요. )

모두 running 중으로 바뀌면 설치가 완료된 것입니다.
만약 running이 아닌 상태라면 각 pod의 마이크로서비스가 실행중 오류가 발생한 것으로 pod 의 log를 확인하여 해결책을 찾을 수 있습니다.

6. web 화면 접근
설치가 끝났지만 어떻게해야 설치된 화면에 들어가는지 조금 애매합니다(kubernetes 환경이 익숙하지 않다면..)

저처럼 kubernetes를 사용하여 설치하셨다면 web ui를 담당하는 pod와 ui에서 발생하는 api를 전송할 api 서버를 외부에서 접근 가능한 상태로 만들어 줘야합니다. kubernetes의 NodePort나 Ingress 등의 방법으로 접근가능하게 할 수있지만, 간단히 kubernetes에서 제공하는 port-forward 기능을 이용해 보겠습니다.(실제 서비스에서 사용하기 위해서는 위의 ignress방법을 추천드립니다. 자세한 내용은 kubernetes 문서를 참조해 주세요)

현재 외부로 노출되어야 하는 마이크로서비스는 deck(ui 서비스)과 gate(api gateway)입니다. 각각 기본적으로 9000 포트와 8084포트를 사용하고 있으며, 로컬로 해당 포트 접근시 pod의 포트로 접근할 수 있도록 설정하겠습니다

kubectl port-forward {Deck POD 이름} -n spinnaker 9000:9000
kubectl port-forward {Gate POD 이름} -n spinnaker 8084:8084
각 파드의 이름을 설정해 주면 localhost로 해당 포트 접근시 pod로 접근 가능합니다.

![image](https://user-images.githubusercontent.com/33619494/188169124-a3a6b980-9727-41b5-a385-917845b8b419.png)
![image](https://user-images.githubusercontent.com/33619494/188169135-4e689a0f-746e-44af-9566-da91c1bcd85e.png)

마치며
여기까지가 기본적으로 spinnaker를 설치하는 방법에 대해 작성해 보았습니다.
정리 하자면 spinnaker 설치를 위해서는 아래와 같은 작업을 하였습니다.

Halyard 설치 - docker 이용
설치될 CloudProvider 설정 - kubernetes 이용
설치 환경 설정 - 분산환경설치 설정
스토리지 설정 - minio
spinnaker 설치
web 화면 접근을 위한 pod port-forward
이 외에 실제 production 환경에서 사용하기 위해서는 인증, 권한, storage의 이중화, 실제 서비스할 계정의 추가, github, jenkins, docker 등의 계정 추가 등등 서비스에 필요한 갖가지 설정이 존재 합니다.
