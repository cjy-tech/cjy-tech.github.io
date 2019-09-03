AWS의 k8s 관련 블로그[https://kubernetes-sigs.github.io/aws-alb-ingress-controller/guide/walkthrough/echoserver/] 를 보고 ALB Ingress 리소스 생성법을 정리한다.

RBAC 및 Ingress Controller 생성
Ingress Controller는 aws에서 제공하는 것을 사용한다(범적으로는 nginx것을 많이 사용한다)

웹에서 rbac과 ingress controller 관련 yaml 파일 다운로드 한다.

wget https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.2/docs/examples/alb-ingress-controller.yaml
wget https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.2/docs/examples/rbac-role.yaml
rbac yaml 파일은 수정할 것 없이 바로 apply 해준다.

kubectl apply -f rbac-role.yaml
ingress controler yaml 파일은 아래와 같이 수정한다.

cluster-name: eks 클러스터 명
spec.template.metadata.annotaions 추가
# Application Load Balancer (ALB) Ingress Controller Deployment Manifest.
# This manifest details sensible defaults for deploying an ALB Ingress Controller.
# GitHub: https://github.com/kubernetes-sigs/aws-alb-ingress-controller
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: alb-ingress-controller
  name: alb-ingress-controller
  # Namespace the ALB Ingress Controller should run in. Does not impact which
  # namespaces it's able to resolve ingress resource for. For limiting ingress
  # namespace scope, see --watch-namespace.
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: alb-ingress-controller
  template:
    metadata:
      annotations:
        iam.amazonaws.com/role: arn:aws:iam::534420079206:role/k8s-alb-controller ### 이부분 추가
      labels:
        app.kubernetes.io/name: alb-ingress-controller
    spec:
      containers:
        - name: alb-ingress-controller
          args:
            # Limit the namespace where this ALB Ingress Controller deployment will
            # resolve ingress resources. If left commented, all namespaces are used.
            # - --watch-namespace=your-k8s-namespace

            # Setting the ingress-class flag below ensures that only ingress resources with the
            # annotation kubernetes.io/ingress.class: "alb" are respected by the controller. You may
            # choose any class you'd like for this controller to respect.
            - --ingress-class=alb

            # REQUIRED
            # Name of your cluster. Used when naming resources created
            # by the ALB Ingress Controller, providing distinction between
            # clusters.
            # - --cluster-name=devCluster ### 이 부분 수정

            # AWS VPC ID this ingress controller will use to create AWS resources.
            # If unspecified, it will be discovered from ec2metadata.
            # - --aws-vpc-id=vpc-xxxxxx

            # AWS region this ingress controller will operate in.
            # If unspecified, it will be discovered from ec2metadata.
            # List of regions: http://docs.aws.amazon.com/general/latest/gr/rande.html#vpc_region
            # - --aws-region=us-west-1

            # Enables logging on all outbound requests sent to the AWS API.
            # If logging is desired, set to true.
            # - ---aws-api-debug
            # Maximum number of times to retry the aws calls.
            # defaults to 10.
            # - --aws-max-retries=10
          # env:
            # AWS key id for authenticating with the AWS API.
            # This is only here for examples. It's recommended you instead use
            # a project like kube2iam for granting access.
            #- name: AWS_ACCESS_KEY_ID
            #  value: KEYVALUE

            # AWS key secret for authenticating with the AWS API.
            # This is only here for examples. It's recommended you instead use
            # a project like kube2iam for granting access.
            #- name: AWS_SECRET_ACCESS_KEY
            #  value: SECRETVALUE
          # Repository location of the ALB Ingress Controller.
          image: docker.io/amazon/aws-alb-ingress-controller:v1.1.2
      serviceAccountName: alb-ingress-controller
ingress controler yaml 파일 apply

kubectl apply -f alb-ingress-controller.yaml
제대로 셋팅 되었는지 로그를 확인

kubectl logs -n kube-system $(kubectl get po -n kube-system | egrep -o alb-ingress[a-zA-Z0-9-]+)
아래와 같은 로그가 나와야 한다.

 -------------------------------------------------------------------------------
AWS ALB Ingress controller
  Release:    v1.1.2
  Build:      git-cc1c5971
  Repository: https://github.com/kubernetes-sigs/aws-alb-ingress-controller.git
-------------------------------------------------------------------------------
W0802 03:41:34.080551       1 client_config.go:549] Neither --kubeconfig nor --master was specified.  Using the inClusterConfig.  This might not work.
I0802 03:41:34.119634       1 :0] kubebuilder/controller "level"=0 "msg"="Starting EventSource"  "controller"="alb-ingress-controller" "source"={"Type":{"metadata":{"creationTimestamp":null}}}
I0802 03:41:34.119958       1 :0] kubebuilder/controller "level"=0 "msg"="Starting EventSource"  "controller"="alb-ingress-controller" "source"={"Type":{"metadata":{"creationTimestamp":null},"spec":{},"status":{"loadBalancer":{}}}}
I0802 03:41:34.120044       1 :0] kubebuilder/controller "level"=0 "msg"="Starting EventSource"  "controller"="alb-ingress-controller" "source"=
I0802 03:41:34.120303       1 :0] kubebuilder/controller "level"=0 "msg"="Starting EventSource"  "controller"="alb-ingress-controller" "source"={"Type":{"metadata":{"creationTimestamp":null},"spec":{},"status":{"loadBalancer":{}}}}
I0802 03:41:34.120344       1 :0] kubebuilder/controller "level"=0 "msg"="Starting EventSource"  "controller"="alb-ingress-controller" "source"=
I0802 03:41:34.120514       1 :0] kubebuilder/controller "level"=0 "msg"="Starting EventSource"  "controller"="alb-ingress-controller" "source"={"Type":{"metadata":{"creationTimestamp":null}}}
I0802 03:41:34.120943       1 :0] kubebuilder/controller "level"=0 "msg"="Starting EventSource"  "controller"="alb-ingress-controller" "source"={"Type":{"metadata":{"creationTimestamp":null},"spec":{},"status":{"daemonEndpoints":{"kubeletEndpoint":{"Port":0}},"nodeInfo":{"machineID":"","systemUUID":"","bootID":"","kernelVersion":"","osImage":"","containerRuntimeVersion":"","kubeletVersion":"","kubeProxyVersion":"","operatingSystem":"","architecture":""}}}}
I0802 03:41:34.121241       1 leaderelection.go:205] attempting to acquire leader lease  kube-system/ingress-controller-leader-alb...
I0802 03:41:34.132720       1 leaderelection.go:214] successfully acquired lease kube-system/ingress-controller-leader-alb
I0802 03:41:34.232985       1 :0] kubebuilder/controller "level"=0 "msg"="Starting Controller"  "controller"="alb-ingress-controller"
I0802 03:41:34.333110       1 :0] kubebuilder/controller "level"=0 "msg"="Starting workers"  "controller"="alb-ingress-controller" "worker count"=1
 

IAM 설정
정책을 생성하고 아래 Json을 넣어준다.

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:GetCertificate"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVpcs",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:RemoveListenerCertificates",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:SetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "tag:GetResources",
        "tag:TagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf:GetWebACL"
      ],
      "Resource": "*"
    }
  ]
}
ingress controler yaml의 iam.amazonaws.com/role을 추가하기 위해 role을 생성한다.

k8s-alb-controller 이름으로 role을 생성하고 위에서 생성한 정책을 붙여준다.

신뢰관계도 아래와 같이 추가한다.

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::534420079206:role/startup-worker-nodes-NodeInstanceRole-J0TTINLVMN46",
          "arn:aws:iam::534420079206:role/staging-conects-worker-nodes-NodeInstanceRole-ASVE5KWIQ6PK",
          "arn:aws:iam::534420079206:role/conects-worker-nodes-NodeInstanceRole-1N7XDXUADP7KT"   ###추가적으로 생성된 Node ARN
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
노드인스턴스의 ARN은 추가될 때 마다 넣어준다.

생성된 Role의 ARN을 ingress controler yaml 파일에 넣어준다.

 

노드 인스턴스 그룹에 IAM Policy 추가
https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.0.0/docs/examples/iam-policy.json

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "acm:DescribeCertificate",
                "acm:ListCertificates",
                "acm:GetCertificate"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:DeleteSecurityGroup",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeTags",
                "ec2:DescribeVpcs",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteRule",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:ModifyRule",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:RemoveTags",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:SetWebACL",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:AddListenerCertificates"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetServerCertificate",
                "iam:ListServerCertificates"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "waf-regional:GetWebACLForResource",
                "waf-regional:GetWebACL",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "tag:GetResources",
                "tag:TagResources"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "waf:GetWebACL"
            ],
            "Resource": "*"
        }
    ]
}
상기 ingressController-iam-policy를 생성하고 Node의 Role에 붙여준다.

 

리소스 배포
deployment와 service를 배포한다.

service yaml은 아래와 같은 형식을 이용한다.

커넥츠용과 단기용 서비스를 전부 만들어준다.

apiVersion: v1
kind: Service
metadata:
  name: "eng3-conects"
spec:
  ports:
    - name: http
      port: 80
      targetPort: 80
  type: NodePort
  selector:
    io.kompose.service: eng3-dangi
 

HTTPS를 위한 노드 그룹 권한 추가
https 를 위해서 aws certi arn 값을 넣는데 이 때 필요한 권한을 노드 인스턴스 롤에 인라인 정책으로 추가한다.

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:AddListenerCertificates"
            ],
            "Resource": "*"
        }
    ]
}
 

s3 어세스 버킷을 위한 설정
버킷과 디렉토리까지 만들어 주고, Policy도 추가해야 한다.

{
    "Version": "2012-10-17",
    "Id": "Policy1563355727968",
    "Statement": [
        {
            "Sid": "Stmt1563355726825",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::600734575887:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::startup-ingress-bucket/startup-web/AWSLogs/534420079206/*"  ###리소스 명 변경해야 한다.
        }
    ]
}
 

Ingress 리소스 생성
wget https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.2/docs/examples/echoservice/echoserver-ingress.yaml
샘플 yaml파일을 다운 받고 수정한다.

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: "conects1-ingress"
  namespace: "default"
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:ap-northeast-2:534420079206:certificate/7e400bd2-6ed0-4cb7-af24-fd5bf8115f32  ## 443포트 이용을 위한 인증서 ARN
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
    alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/security-groups: sg-07e14fdc1d2f31c14 ## 이 보안 그룹을 사용하고, 이 보안 그룹을 쿠버네티스 워커노드 인스턴스에도 all포트로 붙여준다.
    alb.ingress.kubernetes.io/load-balancer-attributes: access_logs.s3.enabled=true,access_logs.s3.bucket=conects-ingress-bucket,access_logs.s3.prefix=conects-web ## access 로그 활성화
  labels:
    app: conects1-ingress
spec:
  rules:
    - host: alb-3eng.conects.com
      http:
        paths:
          - path: /*
            backend:
              serviceName: "eng3-conects"
              servicePort: 80
    - host: alb-nomu.conects.com
      http:
        paths:
          - path: /*
            backend:
              serviceName: "nomu-conects"
              servicePort: 80
ingress는 추가할때마다 NI에 SG 를 붙인다.

그걸 방지하기 위해 보안그룹을 생성하고 워커노드 인스턴스의 보안그룹에 all TCP포트로 붙여준다.

또한 그 보안 그룹을 ingress yaml에도 명시해줘야 추가적인 보안그룹 생성이 방지된다.

보안 그룹을 생성하고 80과 443 포트를 all로 열어준다.

서비스가 추가될 때 마다 ingress에 host를 추가해야 한다.

리소스 생성 후 아래와 같은 로그가 출력된다.

I0802 05:12:19.680733       1 loadbalancer.go:185] default/conects1-ingress: creating LoadBalancer 3ca41399-default-conects1i-176a
I0802 05:12:20.459196       1 loadbalancer.go:201] default/conects1-ingress: LoadBalancer 3ca41399-default-conects1i-176a created, ARN: arn:aws:elasticloadbalancing:ap-northeast-2:534420079206:loadbalancer/app/3ca41399-default-conects1i-176a/b0dd4a69340b97df
I0802 05:12:20.481510       1 attributes.go:144] default/conects1-ingress: Modifying ELBV2 attributes to [{    Key: "access_logs.s3.enabled",    Value: "true"  },{    Key: "access_logs.s3.bucket",    Value: "prod-conects-ingress-bucket"  },{    Key: "access_logs.s3.prefix",    Value: "conects-web"  }].
I0802 05:12:20.593094       1 targetgroup.go:119] default/conects1-ingress: creating target group 3ca41399-70bbfb5a2be3dd8bb42
I0802 05:12:20.826536       1 targetgroup.go:138] default/conects1-ingress: target group 3ca41399-70bbfb5a2be3dd8bb42 created: arn:aws:elasticloadbalancing:ap-northeast-2:534420079206:targetgroup/3ca41399-70bbfb5a2be3dd8bb42/6cb06cd932e262e6
I0802 05:12:20.924084       1 tags.go:43] default/conects1-ingress: modifying tags {  kubernetes.io/service-name: "eng3-conects",  kubernetes.io/service-port: "80",  kubernetes.io/ingress-name: "conects1-ingress",  kubernetes.io/cluster/conects: "owned",  kubernetes.io/namespace: "default"} on arn:aws:elasticloadbalancing:ap-northeast-2:534420079206:targetgroup/3ca41399-70bbfb5a2be3dd8bb42/6cb06cd932e262e6
I0802 05:12:21.214015       1 targets.go:80] default/conects1-ingress: Adding targets to arn:aws:elasticloadbalancing:ap-northeast-2:534420079206:targetgroup/3ca41399-70bbfb5a2be3dd8bb42/6cb06cd932e262e6: i-0202ea68884d223b6:31062, i-004f6fe86cd21dc47:31062
I0802 05:12:21.378520       1 targetgroup.go:119] default/conects1-ingress: creating target group 3ca41399-a62a432a4881d60cf32
I0802 05:12:21.619103       1 targetgroup.go:138] default/conects1-ingress: target group 3ca41399-a62a432a4881d60cf32 created: arn:aws:elasticloadbalancing:ap-northeast-2:534420079206:targetgroup/3ca41399-a62a432a4881d60cf32/876d5dd49bc3742f
I0802 05:12:21.704913       1 tags.go:43] default/conects1-ingress: modifying tags {  kubernetes.io/namespace: "default",  kubernetes.io/ingress-name: "conects1-ingress",  kubernetes.io/service-name: "nomu-conects",  kubernetes.io/service-port: "80",  kubernetes.io/cluster/conects: "owned"} on arn:aws:elasticloadbalancing:ap-northeast-2:534420079206:targetgroup/3ca41399-a62a432a4881d60cf32/876d5dd49bc3742f
I0802 05:12:21.932163       1 targets.go:80] default/conects1-ingress: Adding targets to arn:aws:elasticloadbalancing:ap-northeast-2:534420079206:targetgroup/3ca41399-a62a432a4881d60cf32/876d5dd49bc3742f: i-0202ea68884d223b6:31519, i-004f6fe86cd21dc47:31519
I0802 05:12:22.065031       1 listener.go:110] default/conects1-ingress: creating listener 80
I0802 05:12:22.102400       1 rules.go:60] default/conects1-ingress: creating rule 1 on arn:aws:elasticloadbalancing:ap-northeast-2:534420079206:listener/app/3ca41399-default-conects1i-176a/b0dd4a69340b97df/36355f162825b661
I0802 05:12:22.129777       1 rules.go:77] default/conects1-ingress: rule 1 created with conditions [{    Field: "host-header",    Values: ["alb-3eng.conects.com"]  },{    Field: "path-pattern",    Values: ["/*"]  }]
I0802 05:12:22.129816       1 rules.go:60] default/conects1-ingress: creating rule 2 on arn:aws:elasticloadbalancing:ap-northeast-2:534420079206:listener/app/3ca41399-default-conects1i-176a/b0dd4a69340b97df/36355f162825b661
I0802 05:12:22.164831       1 rules.go:77] default/conects1-ingress: rule 2 created with conditions [{    Field: "host-header",    Values: ["alb-nomu.conects.com"]  },{    Field: "path-pattern",    Values: ["/*"]  }]
I0802 05:12:22.164872       1 listener.go:110] default/conects1-ingress: creating listener 443
I0802 05:12:22.377652       1 rules.go:60] default/conects1-ingress: creating rule 2 on arn:aws:elasticloadbalancing:ap-northeast-2:534420079206:listener/app/3ca41399-default-conects1i-176a/b0dd4a69340b97df/ebd69f32d00baf19
I0802 05:12:22.406331       1 rules.go:77] default/conects1-ingress: rule 2 created with conditions [{    Field: "host-header",    Values: ["alb-nomu.conects.com"]  },{    Field: "path-pattern",    Values: ["/*"]  }]
I0802 05:12:22.406360       1 rules.go:60] default/conects1-ingress: creating rule 1 on arn:aws:elasticloadbalancing:ap-northeast-2:534420079206:listener/app/3ca41399-default-conects1i-176a/b0dd4a69340b97df/ebd69f32d00baf19
I0802 05:12:22.429827       1 rules.go:77] default/conects1-ingress: rule 1 created with conditions [{    Field: "host-header",    Values: ["alb-3eng.conects.com"]  },{    Field: "path-pattern",    Values: ["/*"]  }]
I0802 05:12:22.517332       1 lb_attachment.go:30] default/conects1-ingress: modify securityGroup on LoadBalancer arn:aws:elasticloadbalancing:ap-northeast-2:534420079206:loadbalancer/app/3ca41399-default-conects1i-176a/b0dd4a69340b97df to be [sg-07e14fdc1d2f31c14]
