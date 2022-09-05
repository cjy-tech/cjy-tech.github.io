Ingress
목표
이번에는 아래와 같은 내용에 대해서 학습해보겠습니다.

Ingress가 무엇이고 Ingress Controller는 무엇인지
언제 사용하는지
Ingress를 통해 외부에서 접근해보기
Ingress
네트워크 트래픽은 Ingress와 egress (잘 사용하지는 않는 단어이긴 하지만) 으로 구분된다. Ingress는 외부로부터 서버 내부로 유입되는 네트워크 트래픽을, egress는 서버 내부에서 외부로 나가는 트래픽을 의미한다.

쿠버네티스의 Ingress는 외부에서 쿠버네티스 클러스터 내부로 들어오는 네트워크 요청 : 즉, Ingress 트래픽을 어떻게 처리할지 정의한다. 쉽게 말하자면, Ingress는 외부에서 쿠버네티스에서 실행 중인 Deployment와 Service에 접근하기 위한, 일종의 관문 (Gateway) 같은 역할을 담당한다.

ingress를 사용하지 않았다고 가정했을 때, 외부 요청을 처리할 수 있는 선택지는 NodePort, LB 등이 있을 수 있으나, LB Type의 경우는 외부 인프라스트럭쳐의 도움이 필요하고, 있다고 하여도 비용적인 측면 때문에 모든 서비스에 LB 타입을 사용하려고 하지 않을 것입니다. NodePort 타입의 경우도 초기에는 신박해보일 수 있지만 항상 관리해야 하는 부담이 있습니다.

위 두 방법은 일반적으로 Layer 4 (TCP, UDP) 에서의 요청을 처리하며, 네트워크 요청에 대한 세부적인 처리 로직을 구현하기는 아무래도 한계가 있습니다.

앞서 살펴 보았던 쿠버네티스의 Service는 L4레이어로 TCP 단에서 Pod들을 밸런싱 합니다.
Service의 경우에는 TLS(SSL) 이나, VirtualHost와 같이 여러 호스트명을 사용하거나 호스트명에 대한 라우팅이 불가능하고 URL Path에 따른 라우팅이 불가능합니다.

이를 보완하기 위해 나온 컴포넌트가 쿠버네티스에서 HTTP(S) 기반의 L7 로드밸런싱 기능을 제공하는 컴포넌트를 Ingress 라고 합니다.

개념을 도식화해보면 아래와 같은데 Ingress가 서비스 앞에서 L7 로드밸런서 역할을 하고, URL에 따라서 라우팅을 하게됩니다.

![image](https://user-images.githubusercontent.com/33619494/188171149-eb46cf7e-2ad2-4c45-9ac7-52d479eef70c.png)

Ingress 에서 사용할 수 있는 기능들을 가능한 부분은 아래와 같습니다.

TLS ( Trasport Layer Security )
Name-Based Virtual hosting
Path-Based Routing
Custom rules
예
인그레스를 사용하면 서비스에 다이렉트로 접근하지 않습니다. 단지 ingress Endpoint로 접근하고 해당 리퀘스트는 지정된 서비스로 포워딩되며 아래 ingress 예시를 통해 확인할 수 있습니다.

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
 name: web-ingress
 namespace: default
spec:
 rules:
 - host: blue.example.com
   http:
     paths:
     - backend:
         serviceName: webserver-blue-svc
         servicePort: 80
 - host: green.example.com
   http:
     paths:
     - backend:
         serviceName: webserver-green-svc
         servicePort: 80


위 예제에서 보면 사용자의 blue.example.com / green.example.com 이라는 도메인을 향한 요청은 동일한 ingress Endpoint를 거쳐 각각 도메인에 할당된 서비스( 엄밀히 따지면 서비스의 Endpoint로) 포워딩됩니다.

또한 이렇게도 세팅할 수 있겠죠. example.com/blue , example.com/green
하나는 virtual Hosting을 위한 rule 세팅이 되며 하나는 fan-out 방식입니다. 아래 그림을 보시면 좀 더 이해하기 쉽겠죠?
![image](https://user-images.githubusercontent.com/33619494/188171221-b96b1625-da1d-44b7-9919-393d4ba27819.png)

여기서 잠깐. 쿠버네티스 Resource인 ingress는 어떤 리퀘스트도 본인이 전달해주지 않습니다. 다만 ingress controller 가 해줍니다. ( 난 관리만 할 뿐 일하는 녀석은 따로 있는 거죠. )

Ingress Controller
인그레스 컨트롤러는 Master node의 API 서버를 통해 ingress 리소스의 변화를 모니터링하고 그에 따라 L7 레이어의 load Balancer를 관리하는 역할을 합니다.

GCE L7 Load Balancer 나 Nginx Ingress Controller 등이 대표적입니다. 우리는 minikube를 통해서 작업했기 때문에
minikube에서 사용하는 Nginx Ingress Controller 를 설치해야 합니다

실습
minikube ingress addon 활성화
## minikube ingress Controller 설치 유무 확인 
$ minikube  addons list    

## 인그레스 콘트롤러 활성화 
$ minikube addons enable ingress 

$ kubectl get pods -n kube-system 
![image](https://user-images.githubusercontent.com/33619494/188173256-704d055e-8445-493c-93f4-6de3b1883645.png)

nginx-ingress-Controller 가 설치된 걸 확인하실 수 있습니다.

Ingress 에서 활용할 Service 노출
1. Deployment 생성
$ kubectl run web --image=gcr.io/google-samples/hello-app:1.0 --port=8080
deployment.apps/web created 

2. 외부에 노출 시키기 ( NodePort 타입 )
$kubectl expose deployment web --target-port=8080 --type=NodePort 
service/web exposed 
3. Service 노출 확인하기
kubectl get service 

![image](https://user-images.githubusercontent.com/33619494/188173314-ca17b70c-05b0-4ec6-9cf5-7bc24c9154cc.png)

이전 Service 실습할 때 만들어놓은 web-service 서비스도 함께 보이시죠? ( 혹시 안보이신다면 퀵하게 이전 서비스 실습 첨부파일을 가지고 만들어 보세요. )

4. NodePort를 통해 서비스 동작 여부 확인하기
$ curl http://192.168.99.100:31049 
Hello, world!
Version : 1.0.0
Hostname:web-ddb799d85-xlj8n 

$ curl http://192.168.99.100:30979
You've hit webserver-78cf7f4656-bvxwb
각각 Nodeport로 생성된 서비스이므로 minikube 호스트의 특정 포트로 접근 시 응답을 받을 수 있습니다.

Ingress 생성 및 테스트
첨부된 ingress.yaml 파일 내용

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: example-ingress
spec:
  rules:
  - host: hello.com
    http:
      paths:
      - path: /
        backend:
          serviceName: web
          servicePort: 8080
      - path: /host
        backend:
          serviceName: web-service
          servicePort: 8080
  - host: host.com
    http:
      paths:
      - path: /
        backend:
          serviceName: web-service
          servicePort: 8080
      - path: /host
        backend:
          serviceName: web-service
          servicePort: 8080
      - path: /hello-host
        backend:
          serviceName: web
          servicePort: 8080
각각의 fan-out 방식과 virtual host 방식의 결합된 ingress 생성

$ kubectl apply -f ingress.yaml 
ingress.extensions/example-ingress created 

$ kubectl get ingress
![image](https://user-images.githubusercontent.com/33619494/188173434-be2992d5-c704-4df4-aa90-97214ebd58bc.png)

원래는 ingress controller의 IP Address 가 노출되어야 하지만 10.0.2.15 라는 이상한 IP 가 노출됨.
해당 IP로 access해도 어떠한 응답도 없는 것을 확인할 수 있습니다, .
이유는 쿠버네티스가 설치된 버츄얼 박스와 연관이 있는데 eth0 번에 할당된 IP가 선택되어서 ( 외부와 통신을 위한 임의의 Nat IP ) 실제 동작을 위해서는 mini의 IP인 192.168.99.100 이어야 합니다.

host 등록
도메인 기반의 호출을 위해 etc/hosts 에 아래 레코드 등록 (추후 테스트를 위해 tls.hello.com도 등록 하도록 합니다. )

192.168.99.100 hello.com
192.168.99.100 host.com
192.168.99.100 tls.hello.com
테스트 ( Fan-out , virtual host )
![image](https://user-images.githubusercontent.com/33619494/188173509-68670612-3a6f-4ac5-9622-5bbaf35c9187.png)

TLS 트래픽을 처리하기 위한 Ingress 설정
컨트롤러와 백엔드 포드와는 암호화가 안되어있는 반면에 클라이언트와 컨트롤러 간의 통신은 암호화 되어야 한다.( 아파치 세팅과 비슷한다고 보면 됨 )
결국 SSL을 지원하기 위해 필요한 인증서와 개인키가 필요한데 이 부분을 지난 시간에 학습했던 secret이라는 쿠버네티스리소스에 저장해두고 사용하면 됩니다.

키 생성 및 인증서 생성
$ openssl genrsa -out tls.key 2048 
$ openssl req -new -x509 -key tls.key -out tls.cert -days 360 -subj /CN=tls.hello.com

$kubectl create secret tls tls-secret --cert=tls.cert  --key=tls.key 
secret "tls-secret" created 
tls-ingress 생성
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  tls:                                     (TLS를 지원하는 경우 필요한 설정 은 이 아래 세팅하면 됩니다. ) 
  - hosts:
    - tls.hello.com                ( tls.hello.com 호스트 이름에 대한 tls 연결은 수락된다. ) 
    secretName: tls-secret  ( 비밀키와 인증서는 이전에 생성하였던 tls-secret으로 부터 구할 수 있다. ) 
  rules:
  - host: tls.hello.com
    http:
      paths:
      - path: /
        backend:
          serviceName: web
          servicePort: 8080
      - path: /host
        backend:
          serviceName: web-service
          servicePort: 8080          
Test
특정 도메인에 대한 ssl 접근 가능 여부를 확인합니다.

$ curl -k -v https://tls.hello.com
(사설 인증서의 검증을 예외 시키긴 했지만 handshake 과정에서 등록된 도메인 명등을 확인할 수 있습니다. ) 
![image](https://user-images.githubusercontent.com/33619494/188173613-ff64eedb-80a3-490a-a253-9b70d9ada9ab.png)
