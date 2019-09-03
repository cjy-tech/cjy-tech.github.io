

마스터 노드 구성
EKS 서비스 역할 생성
이 역할은 EKS클러스터 구성 시 필요하다. 이미 eksServiceRole 이름으로 만들었기 때문에 추가적으로 구성할 필요는 없고 그냥 알아둔다.

IAM 콘솔에서 Amazon EKS 서비스 역할을 만든다.
서비스 목록에서 EKS를 선택한 다음 사용 사례에 대해 Allows Amazon EKS to manage your clusters on your behalf(EKS에서 사용자를 대신하여 클러스터를 관리하도록 허용)를 선택
Role name(역할 이름)에서 역할에 대한 고유 이름(예: eksServiceRole)을 입력한 다음 Create role
EKS 클러스터를 위한 VPC, subnet, 보안그룹 생성
VPC, subnet, 보안그룹 은 시스템운영팀 백승국팀장님께서 작업해주신다.
이때 주의할 점은 subnet의 HA를 위해 멀티 az로 구성하도록 한다.
각 az별로 프라이빗과 퍼블릭 subnet을 생성하는데, 프라이빗에는 실제 워커 노드들이 생성되며, 퍼블릭에는 LB들이 생성된다.
프라이빗과 퍼블릭 서브넷에 해당하는 태그와 값을 추가해야 한다.
kubernetes.io/role/internal-elb should be set to 1 or an empty tag value for internal load balancers.
kubernetes.io/role/elb should be set to 1 or an empty tag value for internet-facing load balancers.

클러스터 생성
자세한 내용은 아래 이미지를 참고한다.

주의할점: 서브넷의 설명에 "VPC에서 작업자 노드를 실행할 서브넷을 선택합니다."라고 되어 있어 프라이빗 서브넷만 선택하면 안되고 퍼블릭 서브넷도 선택해 줘야 한다.

kubectl 사용을 위한 aws-iam-authenticator 설치
https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/install-aws-iam-authenticator.html
상기 링크에 설명되어 있으니 그대로 따라하면 자신의 터미널 $PATH에 aws-iam-authenticator가 추가된다.
링크 내용이 바뀔 것을 대비한 이미지는 아래와 같다.

콘솔에서 작업을 완료하고 터미널 환경에서도 kubectl로 관리하기 위해 kubeconfig를 수정한다.
aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME
REGION은 해당 클러스터가 위치할 리전을 적어주면 된다. 보통 서울이니 ap-northeast-2
 CLUSTER_NAME은 3번에서 생성한 클러스터의 이름을 적어준다.
kubectl get svc 명령으로 아래와 같은 결과가 나오는지 확인한다.

워커 노드 구성
ec2로 워커 노드를 구성하는데 ec2를 직접 실행하진 않고 CloudFormation이라는 AWS 서비스로 생성한다.

https://console.aws.amazon.com/cloudformation

상기 주소로 접속한다.

스택 생성
aws에서 제공하는 탬플릿을 사용한다. 
Amazon S3 URL에 아래 주소를 붙여넣기 한다.
https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/amazon-eks-nodegroup.yaml

탬플릿은 현재 아래 내용을 사용한다.
주의) 작업자 노드만 프라이빗 서브넷에 배포하려면 AWS CloudFormation Designer에서 이 템플릿을 편집하고 NodeLaunchConfig의 AssociatePublicIpAddress 파라미터를 false로 수정

---
AWSTemplateFormatVersion: 2010-09-09
Description: Amazon EKS - Node Group

Parameters:

  KeyName:
    Description: The EC2 Key Pair to allow SSH access to the instances
    Type: AWS::EC2::KeyPair::KeyName

  NodeImageId:
    Description: AMI id for the node instances.
    Type: AWS::EC2::Image::Id

  NodeInstanceType:
    Description: EC2 instance type for the node instances
    Type: String
    Default: t3.medium
    ConstraintDescription: Must be a valid EC2 instance type
    AllowedValues:
      - t2.small
      - t2.medium
      - t2.large
      - t2.xlarge
      - t2.2xlarge
      - t3.nano
      - t3.micro
      - t3.small
      - t3.medium
      - t3.large
      - t3.xlarge
      - t3.2xlarge
      - m3.medium
      - m3.large
      - m3.xlarge
      - m3.2xlarge
      - m4.large
      - m4.xlarge
      - m4.2xlarge
      - m4.4xlarge
      - m4.10xlarge
      - m5.large
      - m5.xlarge
      - m5.2xlarge
      - m5.4xlarge
      - m5.12xlarge
      - m5.24xlarge
      - c4.large
      - c4.xlarge
      - c4.2xlarge
      - c4.4xlarge
      - c4.8xlarge
      - c5.large
      - c5.xlarge
      - c5.2xlarge
      - c5.4xlarge
      - c5.9xlarge
      - c5.18xlarge
      - i3.large
      - i3.xlarge
      - i3.2xlarge
      - i3.4xlarge
      - i3.8xlarge
      - i3.16xlarge
      - r3.xlarge
      - r3.2xlarge
      - r3.4xlarge
      - r3.8xlarge
      - r4.large
      - r4.xlarge
      - r4.2xlarge
      - r4.4xlarge
      - r4.8xlarge
      - r4.16xlarge
      - x1.16xlarge
      - x1.32xlarge
      - p2.xlarge
      - p2.8xlarge
      - p2.16xlarge
      - p3.2xlarge
      - p3.8xlarge
      - p3.16xlarge
      - p3dn.24xlarge
      - r5.large
      - r5.xlarge
      - r5.2xlarge
      - r5.4xlarge
      - r5.12xlarge
      - r5.24xlarge
      - r5d.large
      - r5d.xlarge
      - r5d.2xlarge
      - r5d.4xlarge
      - r5d.12xlarge
      - r5d.24xlarge
      - z1d.large
      - z1d.xlarge
      - z1d.2xlarge
      - z1d.3xlarge
      - z1d.6xlarge
      - z1d.12xlarge

  NodeAutoScalingGroupMinSize:
    Description: Minimum size of Node Group ASG.
    Type: Number
    Default: 1

  NodeAutoScalingGroupMaxSize:
    Description: Maximum size of Node Group ASG. Set to at least 1 greater than NodeAutoScalingGroupDesiredCapacity.
    Type: Number
    Default: 4

  NodeAutoScalingGroupDesiredCapacity:
    Description: Desired capacity of Node Group ASG.
    Type: Number
    Default: 3

  NodeVolumeSize:
    Description: Node volume size
    Type: Number
    Default: 20

  ClusterName:
    Description: The cluster name provided when the cluster was created. If it is incorrect, nodes will not be able to join the cluster.
    Type: String

  BootstrapArguments:
    Description: Arguments to pass to the bootstrap script. See files/bootstrap.sh in https://github.com/awslabs/amazon-eks-ami
    Type: String
    Default: ""

  NodeGroupName:
    Description: Unique identifier for the Node Group.
    Type: String

  ClusterControlPlaneSecurityGroup:
    Description: The security group of the cluster control plane.
    Type: AWS::EC2::SecurityGroup::Id

  VpcId:
    Description: The VPC of the worker instances
    Type: AWS::EC2::VPC::Id

  Subnets:
    Description: The subnets where workers can be created.
    Type: List<AWS::EC2::Subnet::Id>

Metadata:

  AWS::CloudFormation::Interface:
    ParameterGroups:
      - Label:
          default: EKS Cluster
        Parameters:
          - ClusterName
          - ClusterControlPlaneSecurityGroup
      - Label:
          default: Worker Node Configuration
        Parameters:
          - NodeGroupName
          - NodeAutoScalingGroupMinSize
          - NodeAutoScalingGroupDesiredCapacity
          - NodeAutoScalingGroupMaxSize
          - NodeInstanceType
          - NodeImageId
          - NodeVolumeSize
          - KeyName
          - BootstrapArguments
      - Label:
          default: Worker Network Configuration
        Parameters:
          - VpcId
          - Subnets

Resources:

  NodeInstanceProfile:
    Type: AWS::IAM::InstanceProfile
    Properties:
      Path: "/"
      Roles:
        - !Ref NodeInstanceRole

  NodeInstanceRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: 2012-10-17
        Statement:
          - Effect: Allow
            Principal:
              Service: ec2.amazonaws.com
            Action: sts:AssumeRole
      Path: "/"
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
        - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
        - arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly

  NodeSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security group for all nodes in the cluster
      VpcId: !Ref VpcId
      Tags:
        - Key: !Sub kubernetes.io/cluster/${ClusterName}
          Value: owned

  NodeSecurityGroupIngress:
    Type: AWS::EC2::SecurityGroupIngress
    DependsOn: NodeSecurityGroup
    Properties:
      Description: Allow node to communicate with each other
      GroupId: !Ref NodeSecurityGroup
      SourceSecurityGroupId: !Ref NodeSecurityGroup
      IpProtocol: -1
      FromPort: 0
      ToPort: 65535

  NodeSecurityGroupFromControlPlaneIngress:
    Type: AWS::EC2::SecurityGroupIngress
    DependsOn: NodeSecurityGroup
    Properties:
      Description: Allow worker Kubelets and pods to receive communication from the cluster control plane
      GroupId: !Ref NodeSecurityGroup
      SourceSecurityGroupId: !Ref ClusterControlPlaneSecurityGroup
      IpProtocol: tcp
      FromPort: 1025
      ToPort: 65535

  ControlPlaneEgressToNodeSecurityGroup:
    Type: AWS::EC2::SecurityGroupEgress
    DependsOn: NodeSecurityGroup
    Properties:
      Description: Allow the cluster control plane to communicate with worker Kubelet and pods
      GroupId: !Ref ClusterControlPlaneSecurityGroup
      DestinationSecurityGroupId: !Ref NodeSecurityGroup
      IpProtocol: tcp
      FromPort: 1025
      ToPort: 65535

  NodeSecurityGroupFromControlPlaneOn443Ingress:
    Type: AWS::EC2::SecurityGroupIngress
    DependsOn: NodeSecurityGroup
    Properties:
      Description: Allow pods running extension API servers on port 443 to receive communication from cluster control plane
      GroupId: !Ref NodeSecurityGroup
      SourceSecurityGroupId: !Ref ClusterControlPlaneSecurityGroup
      IpProtocol: tcp
      FromPort: 443
      ToPort: 443

  ControlPlaneEgressToNodeSecurityGroupOn443:
    Type: AWS::EC2::SecurityGroupEgress
    DependsOn: NodeSecurityGroup
    Properties:
      Description: Allow the cluster control plane to communicate with pods running extension API servers on port 443
      GroupId: !Ref ClusterControlPlaneSecurityGroup
      DestinationSecurityGroupId: !Ref NodeSecurityGroup
      IpProtocol: tcp
      FromPort: 443
      ToPort: 443

  ClusterControlPlaneSecurityGroupIngress:
    Type: AWS::EC2::SecurityGroupIngress
    DependsOn: NodeSecurityGroup
    Properties:
      Description: Allow pods to communicate with the cluster API Server
      GroupId: !Ref ClusterControlPlaneSecurityGroup
      SourceSecurityGroupId: !Ref NodeSecurityGroup
      IpProtocol: tcp
      ToPort: 443
      FromPort: 443

  NodeGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      DesiredCapacity: !Ref NodeAutoScalingGroupDesiredCapacity
      LaunchConfigurationName: !Ref NodeLaunchConfig
      MinSize: !Ref NodeAutoScalingGroupMinSize
      MaxSize: !Ref NodeAutoScalingGroupMaxSize
      VPCZoneIdentifier: !Ref Subnets
      Tags:
        - Key: Name
          Value: !Sub ${ClusterName}-${NodeGroupName}-Node
          PropagateAtLaunch: true
        - Key: !Sub kubernetes.io/cluster/${ClusterName}
          Value: owned
          PropagateAtLaunch: true
    UpdatePolicy:
      AutoScalingRollingUpdate:
        MaxBatchSize: 1
        MinInstancesInService: !Ref NodeAutoScalingGroupDesiredCapacity
        PauseTime: PT5M

  NodeLaunchConfig:
    Type: AWS::AutoScaling::LaunchConfiguration
    Properties:
      AssociatePublicIpAddress: false
      IamInstanceProfile: !Ref NodeInstanceProfile
      ImageId: !Ref NodeImageId
      InstanceType: !Ref NodeInstanceType
      KeyName: !Ref KeyName
      SecurityGroups:
        - !Ref NodeSecurityGroup
      BlockDeviceMappings:
        - DeviceName: /dev/xvda
          Ebs:
            VolumeSize: !Ref NodeVolumeSize
            VolumeType: gp2
            DeleteOnTermination: true
      UserData:
        Fn::Base64:
          !Sub |
            #!/bin/bash
            set -o xtrace
            /etc/eks/bootstrap.sh ${ClusterName} ${BootstrapArguments}
            /opt/aws/bin/cfn-signal --exit-code $? \
                     --stack  ${AWS::StackName} \
                     --resource NodeGroup  \
                     --region ${AWS::Region}
            yum install -y rdate
            ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
            echo "
            *               hard     nofile         655360
            *               soft     nofile         655360
            " >> /etc/security/limits.conf
            cd /home/ec2-user
            wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.5.4-linux-x86_64.tar.gz
            tar xvfz filebeat-6.5.4-linux-x86_64.tar.gz
            cd filebeat-6.5.4-linux-x86_64
            cp filebeat.yml filebeat.yml.org
            cat << 'EOF' > filebeat.yml
            filebeat.config.modules:
              path: ${!path.config}/modules.d/*.yml
              reload.enabled: false
            filebeat.inputs:
              - type: docker
                containers.ids:
                  - '*'
                processors:
                  - add_docker_metadata: ~
            setup.template.name: "eks.conects"
            setup.template.pattern: "eks.conects-*"
            output.elasticsearch:
              index: "eks-conects-%{+yyyy.MM.dd}"
              hosts: ["52.79.56.10:9200"]
            EOF
            ./filebeat -e -v >> filebeat.out 2>&1 &

Outputs:

  NodeInstanceRole:
    Description: The node instance role
    Value: !GetAtt NodeInstanceRole.Arn

  NodeSecurityGroup:
    Description: The security group for the node group
    Value: !Ref NodeSecurityGroup


다음으로 진행하여 아래 이미지및 텍스트와 같이 정보들을 입력해준다.

NodeImageId: 서울리전이고 쿠버네티스 1.12 버전이라면 ami-0a904348b703e620c 사용한다.

NodeVolumeSize: 보통 500GB를 사용


주의할점: 이 서브넷은 워커 노드가 실행될 프라이빗 서브넷만 선택해준다. 마스터 노드 구성에서의 서브넷은 프라이빗과 퍼블릭을 전부 선택했지만 여기서는 프라이빗만 선택한다.

다음으로 진행하여 노드의 태그 값을 지정해준다.
Team: 값, Service: 값

다음으로 진행하여 검토 페이지에서 정보를 검토하고, 스택이 IAM 리소스를 생성할 수 있음을 인지한 다음 생성을 선택
kubectl 로 node 목록 확인
콘솔에서 작업을 마쳐도 kubectl로 워커 노드를 바로 조회 할 수 없다.
config map 리소스를 추가하는 작업을 한다.
yaml 파일 다운로드
curl -o aws-auth-cm.yaml https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/aws-auth-cm.yaml 명령으로 yaml 파일을 다운로드 한다.
yaml 파일 수정

apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: <ARN of instance role (not instance profile)> #### 이 부분을 수정한다.
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
수정할 값은 1번에서 구성한 스택의 NodeInstanceRole이다.

AWS콘솔에서 CloudFormation 서비스를 선택하고 1번에서 구성한 스택을 누른다. 출력 탭을 클릭하면 아래 이미지와 같은 NodeInstanceRole의 값이 있는데 해당 값을 상기 yaml 파일에 붙여 넣는다.



수정한 yaml 적용

kubectl apply -f aws-auth-cm.yaml 명령으로 적용한다.

노드 조회 확인

kubectl get nodes --watch 명령으로 node가 Ready 상태가 되는것을 확인한다.

메트릭 서버
kubectl top 명령을 사용하기 위해 메트릭 서버를 설치한다.

https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/metrics-server.html

상기 주소에 설치법이 나와있다.

 

Nagios 접속 설정
기본적으로 EKS를 구성하면 구성한 사람만 접속 할 수 있게 되어 있다. 하지만 우리는 Nagios 서버의 백승국팀장님 aws 계정 정보로 kubectl명령을 사용해야 한다.

nagios 서버에서 kubectl로 EKS로 구성한 클러스터를 관리 할 수 있도록 작업한다.

aws-iam-authenticator 는 설치되어 있으니(경로: nagios 서버의 /root/bin/aws-iam-authenticator) kubectl 업데이트만 하면 된다.

aws-auth ConfigMap 수정
EKS 클러스터를 구성한 서버의 터미널에서 작업한다(Nagios 서버가 아니다).
kubectl edit -n kube-system configmap/aws-auth 명령
yaml 파일을 수정한다. mapRoles 항목의 12라인 아래에 내용 추가한다.

apiVersion: v1
data:
  mapRoles: |
    - rolearn: arn:aws:iam::534420079206:role/dangi-simul-worker-nodes-NodeInstanceRole-1MJQPZAHKZ79D
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: arn:aws:iam::534420079206:role/KubernetesAdmin                    ##############여기부터
      username: kubernetes-admin
      groups:
        - system:masters                                                         ##############여기까지 추가
  mapUsers: |
    - userarn: arn:aws:iam::534420079206:user/derrick
      username: arn:aws:iam::534420079206:user/derrick
      groups:
        - system:masters
kind: ConfigMap
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"mapRoles":"- rolearn: arn:aws:iam::534420079206:role/dangi-simul-worker-nodes-NodeInstanceRole-1MJQPZAHKZ79D\n  username: system:node:{{EC2PrivateDNSName}}\n  groups:\n    - system:bootstrappers\n    - system:nodes\n"},"kind":"ConfigMap","metadata":{"annotations":{},"name":"aws-auth","namespace":"kube-system"}}
  creationTimestamp: "2019-06-03T07:58:24Z"
  name: aws-auth
  namespace: kube-system
  resourceVersion: "245660"
  selfLink: /api/v1/namespaces/kube-system/configmaps/aws-auth
  uid: 5d2c7ca5-85d5-11e9-92e7-0afe1a18c6f8


저장하고 종료
nagios 서버 kubectl 업데이트
상기 마스터 노드 구성의 5번 항목을 참조하여 작업한다.
aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME --kubeconfig /data/$EKS_CLUSTER_NAME/config
뒤쪽에 --kubeconfig /data/$EKS_CLUSTER_NAME/config 플래그가 추가되는데 nagios 서버는 /data/ 디렉토리 밑에 클러스터별 config 파일을 구분해놨기 때문이다.
추가된 config 파일을 편집기로 수정한다. 20번 째 라인 args 아래로 원 내용 삭제하고 하기 내용을 붙여 넣는다.

- token
- -i
- dangi-simul  ############## EKS 클러스터 명에 따라 바꿔준다
- -r
- arn:aws:iam::534420079206:role/KubernetesAdmin
command: aws-iam-authenticator
env: null
23 라인은 클러스터 명에 따라 달라진다.

리소스 조회 확인
kubectl --kubeconfig=/data/$EKS_CLUSTER_NAME/config get svc 등 명령으로 nagios 서버에서 리소스 조회가 잘 되는지 확인한다.
 

노드 오토스케일링 설정
파드의 리소스가 꽉 차면 파드가 늘어나듯, 노드의 리소스가 부족하면 오토스케일링을 진행해야 한다.

IAM 역할명 확인
aws 콘솔에서 오토스케일링 할 인스턴스의 IAM 역할명을 확인한다.

IAM 역할에 정책 추가
해당 IAM 역할이 담당하는 오토스케일링 그룹의 인스턴스를 관리하므로 오토스케일링 정책을 추가한다.

정책명: ASG-Policy-For-Worker

정책이 추가되었으면 다음 단계 이동
오토스케일링 그룹 명 확인
aws 콘솔에서 오토스케일링 그룹을 확인한다.

오토스케일러 yaml 파일 생성

apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
  name: cluster-autoscaler
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: cluster-autoscaler
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
rules:
- apiGroups: [""]
  resources: ["events","endpoints"]
  verbs: ["create", "patch"]
- apiGroups: [""]
  resources: ["pods/eviction"]
  verbs: ["create"]
- apiGroups: [""]
  resources: ["pods/status"]
  verbs: ["update"]
- apiGroups: [""]
  resources: ["endpoints"]
  resourceNames: ["cluster-autoscaler"]
  verbs: ["get","update"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["watch","list","get","update"]
- apiGroups: [""]
  resources: ["pods","services","replicationcontrollers","persistentvolumeclaims","persistentvolumes"]
  verbs: ["watch","list","get"]
- apiGroups: ["extensions"]
  resources: ["replicasets","daemonsets"]
  verbs: ["watch","list","get"]
- apiGroups: ["policy"]
  resources: ["poddisruptionbudgets"]
  verbs: ["watch","list"]
- apiGroups: ["apps"]
  resources: ["statefulsets"]
  verbs: ["watch","list","get"]
- apiGroups: ["storage.k8s.io"]
  resources: ["storageclasses"]
  verbs: ["watch","list","get"]

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["create"]
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["cluster-autoscaler-status"]
  verbs: ["delete","get","update"]

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: cluster-autoscaler
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-autoscaler
subjects:
  - kind: ServiceAccount
    name: cluster-autoscaler
    namespace: kube-system

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: cluster-autoscaler
subjects:
  - kind: ServiceAccount
    name: cluster-autoscaler
    namespace: kube-system

---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  labels:
    app: cluster-autoscaler
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    metadata:
      labels:
        app: cluster-autoscaler
    spec:
      serviceAccountName: cluster-autoscaler
      containers:
        - image: k8s.gcr.io/cluster-autoscaler:v1.2.2
          name: cluster-autoscaler
          resources:
            limits:
              cpu: 100m
              memory: 300Mi
            requests:
              cpu: 100m
              memory: 300Mi
          command:
            - ./cluster-autoscaler
            - --v=4
            - --stderrthreshold=info
            - --cloud-provider=aws
            - --skip-nodes-with-local-storage=false
            - --nodes=2:30:qa-conects-worker-nodes-NodeGroup-1UGPN3Z4DLSEB   #### 이 부분을 고친다. 예시에서 2 = 최소 노드, 30 = 맥스 노드, 3번에서 확인한 오토스케일링그룹명, 노드 수는 오토스케일링그룹의 최소 최대와 동일해야 한다. 
          env:
            - name: AWS_REGION
              value: ap-northeast-2
          volumeMounts:
            - name: ssl-certs
              mountPath: /etc/ssl/certs/ca-certificates.crt
              readOnly: true
          imagePullPolicy: "Always"
      volumes:
        - name: ssl-certs
          hostPath:
            path: "/etc/ssl/certs/ca-bundle.crt"
상기 yaml 파일 수정하여 kubectl apply 한다.

오토스케일 테스트
https://eksworkshop.com/scaling/test_ca/
상기 주소의 예제를 보고 따라하면 되는데 인스턴스 스펙에 따라 nginx 디플로이먼트의 리소스를 조절한다. 나는 cpu 2 코어, 메모리 2기가정도로 진행했다.
타인이 만든 EKS클러스터에 접근하도록 설정
Nagios 서버 항목에서도 말했듯, EKS는 기본적으로 만든 사람만 접근 할 수 있다. 만약 내 자리에서 타인이 만든 eks 클러스터에 접근하려면? 아래와 같이 하자.

kubeconfig 업데이트
일단 타인이 만든 쿠버네티스 클러스터 정보를 가져와야 한다. 아래 명령 실행
aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME
$REGION과 $CLUSTER_NAME 변수명은 상황에 따라 바뀐다.
kubeconfig 수정
업데이트 된 kubeconfig 는 기본적으로 사용자의 홈 디렉토리의 .kube/config에 저장된다. 편집하자.

- name: arn:aws:eks:ap-northeast-2:534420079206:cluster/dangi-simul                       ############## EKS 클러스터 명에 따라 바꿔준다
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - token
      - -i
      - dangi-simul                                                                       ############## EKS 클러스터 명에 따라 바꿔준다
      - -r                                                                                ############## 새롭게 추가
      - arn:aws:iam::534420079206:role/KubernetesAdmin                                    ############## 새롭게 추가
      command: aws-iam-authenticator
      env: null
현재 KubernetesAdmin 그룹의 구성원은 시스템운영팀 백승국ID, 이동희, 조정열, 최준영, 한예슬 CD로 총 5명이다.

새로운 클러스터를 조회할 수 있는지 확인

보안그룹 정리

EKS 클러스터 생성시 빈 보안그룹 1(수동 생성)

이 그룹은 마스터 노드의 보안 그룹이 되며 그 인바운드 규칙에 워커 노드의 보안그룹이 자동 생성되고 소스로 들어간다.
워커 노드의 보안그룹 1(자동 생성)

노드 끼리 통신 가능하도록 모든 트래픽이 자기 자신을 소스로 하여 들어가있다.
노드의 kubelet과 마스터 노드가 통신하도록 TCP 1025-35535 포트가 마스터 노드의 보안그룹을 소스로 하여 들어가 있다.
노드의 Pod와 마스터 노드의 API 서버가 통신하도록 HTTPS 4443 포트가 마스터 노드의 보안그룹을 소스로 하여 들어가 있다.
ALB Ingress를 위한 보안그룹 1(수동 생성)

80과 443 포트를 0.0.0.0/0으로 허용하는 보안그룹
이 보안그룹을 ALB Ingress 리소스 yaml 파일에 명시적으로 적어줘야 Ingress 리소스를 추가해도, 새로운 보안그룹이 생성되지 않는다.
Bastion Host를 위한 보안그룹 1(수동 생성)

Bastion Host에서 워커노드로 들어가기 위한 22번 포트 보안그룹