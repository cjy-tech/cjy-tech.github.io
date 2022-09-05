금일 목표
* Persistence Storage - Volumes 이 왜 필요한가?
* Volumes Type 에는 어떤 것들이 있나?
* PersistentVolume and PersistentVolumeClaim Obejct 란?
Volume
알다시피 Pod를 구성하는 Container는 단명합니다. 언제든 죽을 수 있죠.
컨테이너가 죽으면 그 안에 저장되어있던 데이터가 모두 삭제됩니다.
Kubelet이 깨끗한 상태에서 해당 컨테이너나 Pod 를 재 시작하겠지만 예전 데이터는 삭제되겠죠?
이런 문제를 해결하기 위해 kubernetes는 Volumes 를 사용합니다.
Volume은 스토리지 매체에 의해서 제공되는 디렉토리이며 스토리지 매체와 그 컨텐츠는 VolumeType에 의해 결정됩니다.
스크린샷 2019-05-26 오후 1.46.33.png

Kubernetes는 이런 Volume을 Pod에 붙이고 그 안의 컨테이너는 해당 Volume을 공유합니다.
물론 컨테이너에서 해당 Volume을 사용하려면 컨테이너 자체에서 접근이 가능하도록 스펙에 정의를 해야 합니다.
볼륨은 팟과 동일한 수명을 가지며, 팟의 컨테이너보다 더 오래 삽니다.
예제 어플리케이션
스크린샷 2019-05-26 오후 2.58.20.png

위 예제 프로그램을 한번 보죠.

세 개의 컨테이너가 있는 포드가 있다고 가정한다.

첫번째 컨테이너는 /var/htdocs 디렉터리에서 HTML 페이지를 서비스하는 웹서버를 실행하고 액세스 로그를 /var/log에 저장한다.
두번째 컨테이너는 html 파일을 생성하고 /var/html 에 저장하는 에이전트를 실행한다.
세번째 컨테이너는 /var/log 디렉토리에서 찾은 로그를 처리한다.
각 컨테이너는 잘 정의된 책임을 가지고 있지만 실제로 별로 쓸모가 없다.

이유는 디스크 스토리지를 공유하지 않기 때문에 컨테이너 이미지 자체의 디렉토리를 접근하기 때문이다.
좌측 구조는 컨테이너별로 위치를 지정해서 저장은 할 수 있겠지만 실제로 동작은 하지 않는다. ( 컨테이너의 스펙은 정상적이지만.. )

적절한 경로에 볼륨을 생성하고 마운트하면 원하는 동작을 할 수 있을 것이다.

이 예제의 두 볼륨은 처음에는 모두 비어있을 수 있으므로 emptyDir라는 볼륨 유형을 사용할 수 있다.

쿠버네티스는 외부 볼륨을 초기화하는 동안 채워지는 유형의 볼륨도 지원하거나 기존 디렉터토리가 볼륨 내부에 마운트 됨다.

볼륨을 채우거나 마운트하는 프로세스는 포드 컨테이너가 시작되기 전에 수행된다.

볼륨은 포드의 라이프사이클에 바인딩되며 포드가 존재할 동안만 존재하지만 볼륨 유형에 따라 포드와 볼륨이
사라진 후에도 파일은 그대로 유지되고 나중에 새 볼륨에 마운트 될 수 있다.

VolumeType
Pod는 여러 유형의 여러 볼륨을 동시에 사용할 수 있으며 , 각 포드의 컨테이너는 볼륨을
마운트하거나 마운트 해제할 수 있다.
emptyDir
empty Volume은 하나의 Pod 가 워커 노드에 스케줄되자 마자 생성됩니다.
일시적인 데이터를 저장하는 데 사용되는 비어있는 단순한 디렉토리
동일 Pod 내에 있는 Container 들끼리만 접근이 가능합니다.
가장 단순한 유형의 볼륨이지만 다른 유형도 이 볼륨을 기반으로 한다.
gitRepo
깃 스토리지의 내용을 체크아웃해 초기화된 볼륨
empty Dir 처럼 Pod가 삭제되면 데이터도 삭제됨.
git repo의 변경사항을 바로 반영하지 않고 pod가 새로 생성될 때 클론하는 방식
figure_6-3.png
hostPath
이름에서도 알 수 있다 시피 워커노드의 파일시스템에서 Pod로 디렉토리를 마운트하는데 사용합니다.
Pod가 삭제되도 볼륨의 내용( 데이터 ) 는 host에 남아있으므로 삭제되지 않는다. ( 첫번 째 영구 스토리지 )
노드에서 시스템 파일을 읽거나 써야 하는 경우에만 사용하는 게 좋음. ( 노드의 로그 파일, kubeconfig, CA 인증서 등등 )
포드 전체에 걸쳐 데이터를 유지하기 위해서는 가급적 사용하지 말자..
단일 클러스터, minikube 같은 경우에나 사용함. 워커 노드가 다수면? 당연한 결과이지 않을까?
hostPath 타입으로 NAS경로를 지정할 수도 있겠지만 별도의 타입으로 또 있겠죠?
스크린샷 2019-05-26 오후 3.55.19.png

gcePersistentDisk, awsElastic-BlockStore , azureDisk
클라우드 제공자에 따른 전용 스토리지를 마운트하는데 사용됨.
각 벤더, 타입 별로 지정
스크린샷 2019-05-26 오후 3.56.37.png
스크린샷 2019-05-26 오후 4.14.40.png

cinder, iscsi, flocker, glusterfs, vsphere-Volume ...
다른 유형의 네트워크 스토리지를 마운트 하는데 사용된다.
사용하지 않는다면 다 알 필요는 없지만 한가지 확인할 수 있는 건 쿠버네ㅣ스에서는 다양한 스토리기술을 지원하며 사용되는 기술은 모두 사용할 수 있다는 것임.
configmap, secret, downwardAPI
특정 쿠버네티스 리소스 및 클러스터 정보를 포드에 노출하는데 사용되는 특수한 유형의 볼륨
persistentVolumeClaim
사전 또는 동적으로 프로비저닝된 영구 스토리지를 사용하는 방법 ( 이는 뒤에 설명합니다. )
기본 스토리지 기술에서 Pod 분리
전통적으로 스토리지는 SE들에 의해서 관리되었습니다. 사용자들은 스토리지 사용에 초점을 맞추고 스토리지 관리에 대해서는 걱정하지 않았었죠.
컨테이너 환경에서 비슷하게 따라가고 싶지만 앞서 봐왔던 많은 볼륨 타입에서 봤다시피 그 자체가 문제가 됩니다. ( 스토리지 관리 )
kubernetes를 사용하는 일반 사용자는 볼륨을 구성하는 스토리지 기술 종류 등을 몰라도 상관없어야 하고 Pod를 요청할 때처럼 쿠버네티스에 스토리지 요구만 하고 싶다.
Kubernetes 에서는 사용자 및 관리자에게 스토리지를 관리하는데 필요한 API를 제공하는 PersisteneVolume이라는 하부 시스템을 통해서 해결했습니다.
PersistentVolume 과 PersistentVolumeClaim 소개
애플리케이션이 인프라 세부사항을 처리하지 않고 쿠버네티스 클러스터의 스토리지를 요청할 수 있도록 두가지 새로운 리소스가 도입됐습니다.
PersistentVolume 과 PersisteneVolumeClaim 입니다.
PersistentVolume
시스템 관리자가 실제 물리 디스크를 생성한 후에, 이 디스크를 PersistentVolume이라는 이름으로 쿠버네티스에 등록합니다.
Pod의 생성/삭제와 별개로 관리자에 의해 쿠버네티스에 등록/ 삭제됩니다.
NameSpace와는 별개로 동작함 ( 특정 사용자에 종속적이지 않는다겠죠 ? )
스크린샷 2019-05-26 오후 2.03.57.png

설정 옵션 설명
Capacity ( 용량 )
VolumeMode ( FileSystem / Raw )
ReClaim Policy
연결된 PVC가 삭제된 후 다시 다른 PVC에 의해 재사용이 가능한데
재 사용 시 디스크 내용을 지울지 유지할지 정책을 설정할 수 있다.
* Reteain : 삭제하지 않고 PV의 내용을 유지한다.
* Recycle : 재사용이 가능하며 재 사용지 자동으로 삭제 후 재사용
* Delete : 볼륨 사용이 끝나면 볼륨 삭제 ( AWS, GCE, Azure 등 )
AccessMode
PV에 대한 동시 접근에 대한 정책을 정의합니다.
ReadWriteOnce(RWO)
하나의 Pod에만 마운트 되고 하나의 Pod에서만 읽고 쓰기가능
ReadOnlyMany(ROX)
여러개의 Pod에 마운트 가능하며 동시 읽기는 가능하나 쓰기 불가
ReadWriteMany(RWX)
여러개 마운트 읽고 쓰기 가능
PersistentVolumeClaims
뭔가 거창한 것 같습니다만 그렇지 않고 API를 통한 Volume 요청( Persistent Volume Claim ) 으로 보시면 됩니다.
사용자의 볼륨 사용 요청의 추상화된 리소스 ( volumeClaim이 있어야 Pod 선언 시 사용 가능 )
Volume과 binding 되어있는지 확인
스크린샷 2019-05-26 오후 2.10.42.png
조금 더 도식화 해보면.
스크린샷 2019-05-26 오후 5.24.18.png

클러스터 관리자는 네트워크 스토리지를 생성합니다
관리자는 쿠버네티스 API에 PV descriptor를 게시함으로서 PV를 만듭니다.
사용자는 PersistentVolumeClaim(PVC)를 생성합니다
쿠버네티스는 적절한 크기 및 액세스 모드의 PV를 찾고 PVC를 PV에 바인딩합니다.
사용자가 PVC를 참조하는 볼륨으로 포드를 생성합니다.
Dynamic Provisioning
관리자가 매번 고객의 요청에 따라 Volume을 생성해주고 증설을 하거나 그렇게 하고 싶을까? 자동화 시대인데..
그래서 쿠버네티스 1.6에서부터 Volume 동적 생성을 지원한다.
물론 스토리지 제공 업체는 별도로 존재해야한다. ( GKE, AWS 같은 )
시스템 관리자가 별도의 디스크를 생성하고 PV를 생성할 필요 없이 PVC만 정의하면 물리 디스크 생성 및 PV 생성을 자동화 해주는 기능이다.
figure_6-10.png

Storage Class
동적 프로비저닝 ( 관리자가 볼륨을 생성해주고 사용할 수 있게 제공해주는 작업을 특정 벤더에게 위임할 때 ) 을 위해서 관리자는 사용할 수 있는 벤더와 벤더에서 요구하는 매개변수들을 정의해야 하는데 이 때 사용되는 추상화 리소스가 스토리지 클래스입니다.
스토리지 클래스 정의 예시

apiversion : storage.k8s.io/v1
kind: StorageClass
metadata:
    name: fast
provisioner: kubernetes.io/gce-pd    (  PV 프로비저닝에 사용할 볼륨 플러그인 )
parameters:
    type: pd-ssd                                    ( 제공자에게 전달된 매개변수 )
    zone: europe-west1-b 
스토리지 클래스를 사용한 PVC 정의

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongodb-pvc 
spec:
  storageClassName: fast     ( PVC는 스토리지 클래스 fast를 이용해서 Volume을 요청한다 ) 
  resources:
    requests:
      storage: 100Mi
  accessModes:
    - ReadWriteOnce
실습
emptyDir
두 가지 컨테이너 ( html-generator , web-server )간 Volume 공유하는 Pod Yaml 파일
apiVersion: v1
kind: Pod
metadata:
  name: fortune
spec:
  containers:
      - image: luksa/fortune     
    name: html-generator
    volumeMounts:
    - name: html
      mountPath: /var/htdocs
  - image: nginx:alpine
    name: web-server
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
      readOnly: true
    ports:
    - containerPort: 80
      protocol: TCP
  volumes:
  - name: html
    emptyDir: {}
html 이라는 empty 볼륨을 만들고 각 컨테이너에서 필요한 디렉토리에 마운트하는 스펙을 정의한 pod 생성

/var/htdocs 하위에 fortune 아웃풋을 만드는 luksa/fortune 이미지를 사용한 컨테이너는 아래 참고

fortune 컨테이너 이미지
fortuneloop.sh

#!/bin/bash
trap "exit" SIGINT
mkdir /var/htdocs

while :
do
  echo $(date) Writing fortune to /var/htdocs/index.html
  /usr/games/fortune > /var/htdocs/index.html
  sleep 10
done
Docker File

FROM ubuntu:latest

RUN apt-get update ; apt-get -y install fortune 
ADD fortuneloop.sh /bin/fortuneloop.sh

ENTRYPOINT /bin/fortuneloop.sh

$ kubectl port-forward fortune 8888:80

$ curl http://localhost:8080
Beware of a tall blond man with one black shoe

Persistent Volume Claim 사용해보기
다음과 같은 순서로 작업해보겠습니다.
PV 생성

PVC 생성

해당 Storage를 사용하는 Pod deploy 테스트

Minikube 내에 특정 디렉토리를 사용하고 일정 사이즈 만큼 사용할 수 있도록 PV 생성

kind: PersistentVolume
apiVersion: v1
metadata:
  name: test-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual    
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:                         ( hostPath 타입 ) 
    path: "/mnt/data"
PVC.yml

kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
pod.yml

kind: Pod
apiVersion: v1
metadata:
  name: test-pv-pod
spec:
  volumes:
    - name: test-pv-storage
      persistentVolumeClaim:
       claimName: test-pv-claim
  containers:
    - name: test-pv-container
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: test-pv-storage
각 설정 파일을 적용해보고 내용 확인하기
minikube에서 사용할 수 있는 hostPath 타입 PV 생성

$ kubectl get pv 
$ kubectl apply -f PV.yaml
스크린샷 2019-05-27 오후 2.01.47.png

위에서 생성한 PV를 사용하기 위한 PVC 생성

$ kubectl get pvc 
$ kubectl apply -f PVC.yml
스크린샷 2019-05-27 오후 2.03.38.png

이제 PVC를 통해 할당된 스토리지 사용하는 Pod 생성 테스트

$ kubectl apply -f pod.yaml
$ kubectl exec  -it test-pv-pod /bin/bash
root@test-pv-pod:/# apt update
root@test-pv-pod:/# apt install curl
root@test-pv-pod:/# curl localhost
