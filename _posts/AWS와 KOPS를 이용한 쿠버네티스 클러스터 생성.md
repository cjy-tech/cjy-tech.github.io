요약
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: kops/v1alpha2
kind: Cluster
metadata:
  creationTimestamp: 2018-10-30T02:47:54Z
  name: k8s.princetonreviewprep.com
spec:
  api:
    dns: {}
    loadBalancer:
      additionalSecurityGroups:
      - sg-dde92db5
      - sg-c4e92dac
      type: Public
  authorization:
    rbac: {}
  channel: stable
  cloudConfig:
    disableSecurityGroupIngress: true
    elbSecurityGroup: sg-dde92db5
  cloudProvider: aws
  configBase: s3://st-k8s-tpr/k8s.princetonreviewprep.com
  dnsZone: princetonreviewprep.com
  etcdClusters:
  - etcdMembers:
    - instanceGroup: master-ap-northeast-2a
      name: a
    name: main
  - etcdMembers:
    - instanceGroup: master-ap-northeast-2a
      name: a
    name: events
  iam:
    allowContainerRegistry: true
    legacy: false
  kubernetesApiAccess:
  - 0.0.0.0/0
  kubernetesVersion: 1.9.8
  masterInternalName: api.internal.k8s.princetonreviewprep.com
  masterPublicName: api.k8s.princetonreviewprep.com
  networkCIDR: 10.251.0.0/16
  networkID: vpc-ebd29c82
  networking:
    kubenet: {}
  nonMasqueradeCIDR: 100.64.0.0/10
  sshAccess:
  - 0.0.0.0/0
  subnets:
  - cidr: 10.251.10.0/24
    id: subnet-7a7c2213
    name: ap-northeast-2a
    type: Public
    zone: ap-northeast-2a
  topology:
    dns:
      type: Public
    masters: public
    nodes: public
상기 파일을 생성 후, `kubectl apply -f create_cluster.yaml` 명령으로 생성 할 수 있다.

 

Nagios 서버에서 진행해야 한다(Nagios 서버는 kops까지 설치되어 있으니, 클러스터 구성의 2번부터 보면 된다)
선행 조건
클라이언트로 사용할 곳에 'kubectl' 설치
https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-using-native-package-management
상기 url에서 OS에 맞는 버전을 설치한다. 아래는 CentOS 및 RHEL, Fedora 계열의 예시이다.

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubectl


'kubectl'이 설치된 클라이언트에 'AWS CLI' 설치
https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/installing.html
상기 URL을 참고하여 설치한다.
클러스터 구성
'kubectl'이 설치된 클라이언트에 'kops'설치

curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops


AWS Route53 도메인 생성
https://console.aws.amazon.com/route53/home?region=ap-northeast-2#hosted-zones:
kops는 (클러스터 내에서도) DNS를 이용하여 클라이언트에서 쿠버네티스 서버로 연결 할 수 있다.
클러스터를 구분하기 위해 서브 도메인을 사용해야 한다. 예를 들어 'princetonreviewprep.com'라는 Hosted Zone을 생성하면, 그 하위 Record Set인 'example.princetonreviewprep.com'이 클라이언트가 접속하는 쿠버네티스 API의 엔드 포인트가 된다.

유효한 Hosted Zone을 생성

생성한 Hosted Zone에 유효한 Record Set을 추가


AWS S3 버킷 생성
클러스터 상태 및 config를 저장하기 위한 전용 S3버킷이 필요하다.

`aws s3 mb s3://$생성하고자 하는 버킷 이름`

`export KOPS_STATE_STORE=s3://$생성하고자 하는 버킷 이름`
변수를 export 함으로써 kops가 그 위치를 기본적으로 사용하게 된다.

클러스터 config 생성
`kops create cluster --cloud=aws --zones=ap-northeast-2a --name=k8s.$Hosted zone --dns-zone=$Hosted zone --dns public`

클러스터 config 수정

`kops edit cluster k8s.$Hosted zone` 명령을 실행하면 vim으로 수정 가능한 yaml 파일이 나온다(본 문서의 가장 상위 요약에 나와있는 양식처럼).
로드밸런서, VPC 대역 등을 수정한다.
`kops edit ig --name=k8s.$Hosted zone nodes` 명령으로 node 설정을 변경 할 수 있다(용량, 노드 갯수, CPU 종류 등 수정).
`kops edit ig --name=k8s.$Hosted zone master-ap-northeast-2a` master node 설정을 변경 할 수 있다(용량, 노드 갯수, CPU 종류 등 수정).
apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  creationTimestamp: 2018-10-30T02:47:54Z
  labels:
    kops.k8s.io/cluster: k8s.princetonreviewprep.com
  name: nodes
spec:
  image: kope.io/k8s-1.9-debian-jessie-amd64-hvm-ebs-2018-08-17
  machineType: c4.xlarge ## CPU 종류
  maxSize: 2 ## 노드 최대
  minSize: 2 ## 노드 최소
  nodeLabels:
    kops.k8s.io/instancegroup: nodes
  role: Node
  subnets:
  - ap-northeast-2a


`kops update cluster k8s.$Hosted zone --yes` 명령으로 클러스터 생성

클러스터 업데이트(선택적)
클러스터 생성 후 노드 변경사항을 적용하기 위해 `kops update cluster --yes`명령을 사용한다.
이 명령은 앞으로 생성될 클러스터에 반영되고 현재 이미 생성되어 있는 클러스터에는 영향을 미치지 않는다.
현재 생성되어 있는 클러스터를 변경하기 위해 `kops rolling-update cluster --yes`명령을 사용한다.

클러스터 검증
`kops validate cluster` 명령으로 cluster 가 정상적으로 셋팅되어 있는지 확인(Update 를 수행하고 약 10분후에 정상적으로 실행된다.)


unexpected error during validation: error listing nodes: Get https://api.k8s-staging.princetonreviewprep.com/api/v1/nodes: dial tcp 13.124.115.54:443: i/o timeout
상기와 같은 에러가 발생하면 master 노드의 sg에 443포트를 열어준다.


`kubectl get nodes` 명령으로 node 들이 정상적으로 ready 상태인지 확인

인스턴스 확인
https://ap-northeast-2.console.aws.amazon.com/ec2/v2/home?region=ap-northeast-2#Instances:sort=tag:Name
상기 URL에서 생성한 클러스터 이름으로 검색하여 정상적으로 생성되었는지 확인한다.

노드 보안그룹에 인바운드 규칙 추가
https://ap-northeast-2.console.aws.amazon.com/vpc/home?region=ap-northeast-2#securityGroups:
상기 URL에서 생성한 클러스터 이름으로 검색하여 노드의 인바운드를 추가한다.

참고) ELB가 노드 인스턴스에 Health Check를 하는데, ELB가 속해있는 VPC의 보안그룹을 인스턴스에 추가하지 않으면 접속이 안된다. 그러므로 상기 10번의 보안그룹 규칙 추가가 필요하다.
         HTTPS 443 포트도 추가해준다


쿠버네티스 관리 UI인 대시보드 설치 필요
https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/dashboard-tutorial.html

상기 링크 참조하여 설치
링크에 나와있지 않은 apply 명령 2개도 추가

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/metrics-server/v1.8.x.yaml
error: heapster 관련한 것은 아래 파일 복사해서 apply

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: metrics-server
  namespace: kube-system
  labels:
    k8s-app: metrics-server
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  template:
    metadata:
      name: metrics-server
      labels:
        k8s-app: metrics-server
    spec:
      serviceAccountName: metrics-server
      volumes:
      # mount in tmp so we can safely use from-scratch images and/or read-only containers
      - name: tmp-dir
        emptyDir: {}
      containers:
      - name: metrics-server
        image: k8s.gcr.io/metrics-server-amd64:v0.3.1
        imagePullPolicy: Always
        args:
        - --kubelet-insecure-tls
        volumeMounts:
        - name: tmp-dir
          mountPath: /tmp

aws instance는 시간대가 한국시간으로 맞춰서 생성되지 않는다. 시간을 맞춰준다.
먼저 설정하기 전에 `date`명령을 쳐서 시간대가 어떤지 보자.
이 후 아래 3명령을 적용한다.

apt-get install rdate
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
rdate -s time.bora.net
systemctl restart rsyslog
상기 3줄 명령을 모두 실행하고 `date` 명령을 입력하면 시간대가 잘 나온다.


노드 인스턴스의 용량 이슈인지 확실하진 않지만, k8s pod 생성 에러가 발생하며 생성되지 않을 때가 있다. 
그 경우 `kubectl describe deploy $해당디플로이명` 명령을 쳐서 아래와 같은 에러 메시지가 있는지 확인해보자

Events:
 Type     Reason                 Age                From                                                       Message
 ----     ------                 ----               ----                                                       -------
 Normal   Scheduled              40s                default-scheduler                                          Successfully assigned bupgum-dangi-8556bb7bf8-fpshz to ip-10-120-60-173.ap-northeast-2.compute.internal
 Normal   SuccessfulMountVolume  40s                kubelet, ip-10-120-60-173.ap-northeast-2.compute.internal  MountVolume.SetUp succeeded for volume "default-token-77gff"
 Warning  Failed                 36s                kubelet, ip-10-120-60-173.ap-northeast-2.compute.internal  Failed to pull image "534420079206.dkr.ecr.ap-northeast-2.amazonaws.com/bupgum_dangi:latest": rpc error: code = Unknown desc = failed to register layer: link /var/lib/docker/overlay/71e3b4e19a52c19805c86632c8e52930362788bc390071ba92baafbf80a68b48/root/usr/libexec/git-core/git-merge-tree /var/lib/docker/overlay/6abe6da849374d1791065d43bd99234d3a4cc2c866180261c51fd879eb3abec5/tmproot044019859/usr/libexec/git-core/git-merge-tree: too many links
해당 에러를 방지하기 위해 crontab 작업을 해준다.
`crontab -e`명령을 쳐서 crontab작업 편집기를 실행한다. 처음 생성한 인스턴스는 어떤 편집기를 선택할지 물어본다. nano, vim 중 편한 것을 선택하자.

00 11   * * *   root    docker system prune -a -f >> /home/admin/prune.log
상기 명령을 붙여넣기 하고 저장후 편집기를 나간다.
crontab을 재시작 한다.

systemctl restart cron
참고: https://stackoverflow.com/questions/48673513/google-kubernetes-engine-errimagepull-too-many-links

 

Kubelet 'failed to get cgroup stats for "/system.slice/kubelet.service"' error messages
편집기로 파일 수정

vim /etc/sysconfig/kubelet
DAEMON_ARGS 값 뒤에 아래 내용 추가

--runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice

sed -i 's/net.d\/ --cni-bin-dir=\/opt\/cni\/bin\/\"/net.d\/ --cni-bin-dir=\/opt\/cni\/bin\/ --runtime-cgroups=\/systemd\/system.slice --kubelet-cgroups=\/systemd\/system.slice\"/g' /etc/sysconfig/kubelet
혹은 `sed` 바이너리로 작업해도 된다.
이후, kubelet 재시작

sudo systemctl restart kubelet
참고: https://github.com/kubernetes/kops/issues/4049

 

linux limits 수정

vi /etc/security/limits.conf
*               hard    nofile          655360
*               soft    nofile          655360


ec2 instance 오토 스케일링 설정
nagios 서버의 `/home/jycho` 경로에 `cluster-autoscaler-*.yml`파일이 존재한다.
와일드카드(*)는 쿠버네티스 서비스 이름으로 바꾸어준다.
해당 파일을 열어 223 라인의 내용을 수정한다.
- --nodes=13:20:nodes.k8s.conects.com
노드의 최소 갯수, 뒤에는 최대 갯수, 노드인스턴스이름으로 수정한다.
`kubectl apply -f cluster-autoscaler-*.yml`으로 적용한다.