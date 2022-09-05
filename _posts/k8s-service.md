목표
어플리케이션에 접근하기 위한 Service로 묶는 방법의 장점
각 노드들에서 동작하는 Kube-proxy의 역할
쿠버네티스에서 사용할 수 있는 Service Discovery option
Service Type의 차이점
GUI 환경하에서 어플리케이션 배포
NordPort Service Type으로 외부에 노출시키기
Pod 한계
Pod는 언제든 죽을 수 있는 리소스기 때문에 IP 주소들 같은 리소스들이 정적일 수 없다.
언제든 다른 Node로 할당된다던가 / 다른 인스턴스로 생성될 수 있다.
예를 들어 아래 그림을 봅시다.
스크린샷 2019-05-10 오전 10.53.11.png

클라이언트가 Pod 에 직접 접근을 하고 있다고 가정했을 때 pod가 죽어서 컨트롤러에 의해 새로운 pod 가 생성되면 별도의 새 IP 가 할당되나 사용자들은 이 사실을 알지 못합니다.
이런 상황을 극복하기 위해 쿠버네티스에서는 Label과 Selector를 통해 논리적으로 Pod를 그룹핑하고 접근할 수 있는 Service라는 상위 레벨의 추상화를 제공합니다.

Service
Label 을 통해 그룹핑 된 그림 예를 한번 보죠.
스크린샷 2019-05-10 오전 11.04.43.png

selector를 통해 ( app==frontent , app==db ) 우리는 이름을 부여한 두 개의 논리적 그룹( frontent-svc, db-svc )을 만들 수 있습니다.
Service는 클러스터내에서 접근이 가능한 IP 어드레스를 기본으로 할당받고 이를 그 Service의 ClusterIP라고 합니다.
클라이언트는 IP Adress를 통해 Service에 접근이 가능하게 되고 Service는 요청 트래픽을 넘겨줄 Pod들이 선택되는 동안에는 loadbalancing을 합니다.
서비스에서 트래픽을 전달하면서 포드에서 대상 포트를 선택할 수 있습니다.
위 그림에서 보면 80포트로 요청을 받아서 서비스에 묶인 Pod들 중 하나에 5000번 포트로 전달하게 세팅되어있고 트래픽을 받으면 해당 포트로 넘겨주게 됩니다.
위와 같은 서비스의 예제 Yaml 파일
kind: Service
api
Version: v1

metadata:
  
 name: frontend-svc

spec:
  
 selector:
    
   app: frontend
  
 ports:
    
  - protocol: TCP
      
    port: 80
      
    targetPort: 5000
이 예제에서 app = frontend 라는 라벨을 가진 pods 들로 연결될 frontend-svc 라는 서비스를 만들었습니다.
각 서비스는 클러스터내에서만 접근이 가능한 IP 주소를 기본으로 갖게 되는데 예제에서는 172.17.0.4 ( frontend-svc ) , 172.17.0.5 ( db-svc ) 를 가지게 되고 각 서비스에 할당됩니다.
클라이언트는 각각 할당된 IP 주소의 80포트를 통해 해당 서비스에 접근하게 되고 서비스의 엔드포인트로( 10.0.1.3:5000, 10.0.1.4:5000, 10.0.1.5:5000) 트래픽을 포워딩합니다.
Kube-Proxy
모든 워커노드에는 Service와 endpoint의 생성과 추가를 API를 통해 감시하고 있는 kube-proxy라는 데몬이 동작합니다.
새로운 서비스가 등록/삭제되면 각 노드들에서 kube-proxy가 ClusterIP에 인입되는 트래픽을 잡아서 엔드포인트로 포워딩하기 위해 Iptable에 변경합니다.
스크린샷 2019-05-12 오후 3.12.27.png

Service Discovery
쿠버네티스에서 Service가 기본 소통방식이기때문에 런타임 환경에서 서비스들을 찾을 수 있어야 하며 쿠버네티스에서는 두 가지 방식을 제공합니다.
Environment Variables
Pod 가 어떤 노드에서 시작되는 순간 해당 노드에서 동작하는 kubelet 데몬은 해당 Pod 내에 현재 동작하는 Service를 위한 환경 변수를 추가합니다.
예를 들면 redis-master 라는 서비스가 있고 6379포트로 노출되며 ClusterIP가 172.17.0.6이라는 서비스가 있다고 한다면 새로 생기는 Pod에서는 아래와 같은 환경 변수를 볼 수 있습니다.
REDIS_MASTER_SERVICE_HOST=172.17.0.6
REDIS_MASTER_SERVICE_PORT=6379

REDIS_MASTER_PORT=tcp://172.17.0.6:6379

REDIS_MASTER_PORT_6379_TCP=tcp://172.17.0.6:6379

REDIS_MASTER_PORT_6379_TCP_PROTO=tcp
REDIS_MASTER_PORT_6379_TCP_PORT=6379

REDIS_MASTER_PORT_6379_TCP_ADDR=172.17.0.6
한 가지 문제점은 Pod 가 생성된 후에 서비스가 추가 생성되었다면 그 Pod는 나중에 생성된 서비스의 환경변수를 가지고 있지 않기 때문에 서비스의 생성 순서에 대해서 주의를 기울여야 합니다.
DNS
쿠버네티스는 Service를 위해 my-svc.my-namespace.svc.cluster.local 같은 포맷을 가진 DNS 레코드를 생성하는 Add-on 기능이 있으며, 동일한 네임스페이스 안에서 이름으로 다른 서비스들을 접근할 수 있습니다.
예를 들어 redis-master라는 Service가 my-ns 라는 Namespace가 있다면 동일 네임스페이스 내의 모든 Pod는 redis 서비스에 접근하기 위해서 redis-master 이름을 통해서 접근이 가능합니다.
다른 네임스페이스에서 접근하려면 아래와 같은 이름을 사용합니다.
redis-master.my-ns 
Service Type
Service를 정의하면서 그 접근 범위를 지정하게 되는데 범위를 아래와 같이 지정할 수 있습니다.
클러스터 내부에서만 접근이 가능한.
클러스터 내부 / 외부
클러스터 내부에 존재하는 외부 객체를 위한 매핑
ServiceType:ClusterIP , NodePort
ClusterIP는 기본 Service Type으로 ClusterIP라는 가상의 IP를 갖게 됩니다.
NodePort Service Type은 ClusterIP외에 모든 워커 노드에 서비스를 위한 30000~32767범위의 포트를 가지게 됩니다.
예를 들어 frontend-svc 를 위해 32233 포트를 지정한다면 어떤 노드에서든 32233 포트로 트래픽을 보내면 해당 노드는 ClusterIP ( 172.17.0.4 ) 로 리다이렉트 시킵니다.
별도의 포트를 지정하지 않으면 자동으로 할당합니다.
스크린샷 2019-05-12 오후 3.40.17.png

ServiceType:LoadBalancer
클라우드 프로바이더에서 제공하는 Loadbalancer 기능을 활용하는 ServiceType으로 ClusterIP, NodePort를 생성하고 외부 loadbalancer는 해당 서비스로 라우팅 설정합니다.
스크린샷 2019-05-12 오후 3.44.12.png

ServiceType:ExternalIP
쿠버네티스를 통해 관리되고 있지 않은 특정 IP를 서비스에 매핑시킴으로서 클러스터로 유입되는 트래픽서비스 포트의 IP(대상 IP)가 서비스 끝점 중 하나로 라우팅할 수 있습니다.
스크린샷 2019-05-13 오후 3.00.19.png

ServiceType : ExternalName
외부 서비스( DNS ) 기반의 서비스로의 접근을 담당하기 위해 사용되며 외부 서비스로 포워딩 되기 때무네 별도로 ClusterIP를 할당받지는 않는다.
실습 시작 전 체크 ( Kubectl config )
Kubectl
쿠버네티스에서 제공하는 CLI 도구로 항상 $HOME/.kube 디렉토리를 참고합니다.
우선 config 관련한 부분만 먼저 볼 거구요 더 자세한 내용은 아래 링크 참고
https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands
$ vi ~/.kube/config                                        # kubectl이 참고하는 config 파일 

$kubectl config view                                     # 이렇게도 볼 수 있습니다.

$ kubectl config get-contexts                       # 컨텍스트 리스트를 볼 수도 있구요 
    
$ kubectl config current-context                  # 현재 사용중인 컨텍스트가 무엇인지 확인합니다.

$kubectl config use-context docker-for-desktop      # 현재 사용하는 컨텍스트를 바꿀 수도 있고 

$ kubectl config get-contexts

$ kubectl config use-context minikube       

$ kubectl config set-context --current --namesapace=default     # 현재 사용하는 컨텍스트의 기본 네임스페이스를 지정하기도 합니다. 

편의 기능 설치
context 설정을 좀 편하게 해주는 도구입니다. ( 기본 네임스페이스 등 )
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

스크린샷 2019-05-12 오후 4.55.01.png

실습 목표
1. GUI 환경을 통해 어플리케이션을 배포하는 방법을 확인한다.
2. 배포된 어플리케이션을 Service를 통해 노출시킨다. ( NodePort )
minikube dashboard 띄우고 오른쪽 상단의 Create 를 누릅니다.
$minikube dashboard 
Yaml 형식이나 JSon 형식을 Text 입력 도구 , 파일, GUI를 통한 리소스 생성 화면
스크린샷 2019-05-12 오후 5.01.57.png

Application을 생성해볼게요.
스크린샷 2019-05-12 오후 5.02.48.png

Advanced Options 를 클릭해서 추가적으로 label 이나 Namespace등을 설정할 수 있습니다. 새 네임스페이스 생성 후 gui-test 라는 네임스페이스를 등록해볼게요.
스크린샷 2019-05-12 오후 5.07.35.png

일정 시간이 지나면 아래와 같은 화면을 볼 수 있습니다.
스크린샷 2019-05-12 오후 5.08.38.png

다른 커맨드 창을 띄워서 위에 생성된 리소스들을 확인해보죠.
$ kubectl get deploymens 
No resources found.
어 분명 생성했는데 왜 안나올까요?
힌트 : Namespace

Deploying Application Using with GUI
현재 default Namespace를 사용하고 있기 때문에 안나오는 거였습니다. Namespace를 바꿔볼게요. 앞서 설정한 툴을 이용하면 변경하기 쉽습니다.
$kubectl get deployments -n gui-test 

$kubens gui-test 
$kubectl get deployments
$kubectl get rs 
$kubectl get po

스크린샷 2019-05-12 오후 5.12.58.png

NodePort를 통해 외부에 서비스 노출시키기
web-service.yml 파일 생성
apiVersion: v1
kind: Service
metadata:
  labels:
    app: kubia
  name: web-service
spec:
  ports:
  - port: 8080
    protocol: TCP
  selector:
    k8s-app: webserver
  type: NodePort
CLI를 통한 서비스 생성
$ kubectl create -f web-service.yml
service/web-service created 
GUI 의 text inpu or file을 통한 생성도 동일함
생성된 Service 확인
$kubectl get svc web-service
$kubectl describe svc web-service
스크린샷 2019-05-13 오후 2.18.43.png

GUI 환경하에서 서비스 확인
스크린샷 2019-05-13 오후 2.15.20.png

이제 서비스에 접근해볼까요?
NordPort 타입으로 생성했기 때문에 동작하는 모든 노드의 port ( 30045 ) 는 static하게 오픈됩니다. ( 물론 minikube는 워커 노드가 1개이므로 하나만 세팅됐지만 동작은 동일합니다. )
워커 노드의 30045포트로 접근하는 트래픽은 서비스의 엔드포인트 ( 172.17.0.14:8080, 172.17.0.15:8080)로 포워딩 됩니다.
한번 띄워보죠. ( minikube IP가 뭐였더라.. )
minikube에서 제공하는 툴을 사용하면 좀 더 수월하게 확인이 가능합니다.
$minikube service list 
|-------------|----------------------|-----------------------------|
|  NAMESPACE  |         NAME         |             URL             |
|-------------|----------------------|-----------------------------|
| default     | kubernetes           | No node port                |
| default     | kubia-http           | No node port                |
| gui-test    | web-service          | http://192.168.99.100:30045 |
| gui-test    | web-service2         | http://192.168.99.100:32737 |
| kube-system | default-http-backend | http://192.168.99.100:30001 |
| kube-system | kube-dns             | No node port                |
| kube-system | kubernetes-dashboard | No node port                |
|-------------|----------------------|-----------------------------|

$ minikube service --url --namespace gui-test web-service
http://192.168.99.100:30045

$ minikube service --namesapace gui-test web-service

