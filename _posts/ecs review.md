## ECS task definition
- 태스크 정의는 애플리케이션을 구성하는 하나 이상의 컨테이너를 설명하는 텍스트 파일
- JSON 형식
- 최대 10개의 컨테이너를 설명하는 데 사용
- 전체 애플리케이션 스택이 단일 태스크 정의에 있을 필요는 없음
- 실제로 여러 태스크 정의에 걸쳐 애플리케이션을 확장하는 것이 좋음
- 이를 위해서는 관련 컨테이너를 자체 태스크 정의(각각 단일 구성 요소를 나타냄)로 결합하면 됨
  - 정리하면 docker-compose 처럼 여러 컨테이너를 실행하는 것에 대한 정의인데 최대 컨테이너 10개, 형식이 yaml이 아닌 json
  - 하지만 docker-compose처럼 여러 컨테이너를 정의하는 것보다는 단일 구성 요소를 결합? 하는것이 best practice로 보임
  - 참고: https://docs.aws.amazon.com/ko_kr/AmazonECS/latest/developerguide/application_architecture.html

### fargate일 경우 task definition
다음의 조건이 필요한 경우, 단일 태스크 정의에 여러 컨테이너를 배포하는 것이 좋음
1. 컨테이너가 공통 수명 주기를 공유하는 경우(즉, 함께 시작하고 종료).
2. 컨테이너가 동일한 기본 호스트에서 실행되어야 하는 경우(즉, 로컬호스트 포트에서 한 컨테이너가 다른 컨테이너를 참조함)
3. 컨테이너가 리소스를 공유해야 하는 경우.
4. 컨테이너가 데이터 볼륨을 공유하는 경우
위 조건을 만족하지 않을 경우 여러 태스크 정의에 따로 컨테이너를 배포하는 것이 좋음

### ECS task role
- 태스크가 aws 리소스등을 사용할 때 필요한 role과 policy
- `Task execution role`과 다름, 해당 role은 컨테이너 에이전트가 ecs 서비스와 작업하기 위한 role과 policy

## ECS task
- 독립 실행형 태스크(배치같은)를 실행하거나 서비스의 일부로 태스크를 실행할 수 있음
  - 서비스는 Amazon ECS 클러스터에서 원하는 수의 태스크를 동시에 실행하고 유지할 수 있음(지속 가능한 어플리케이션)
  - 즉, 서비스에는 태스크를 몇개 실행할지 정의하는 것 같음, 그리고 서비스의 메타데이터가 필요할 듯(service description)
- 태스크는 클러스터 내 태스크 정의를 인스턴스화하는 것
- 태스크 정의를 생성하면 클러스터에서 실행할 태스크 수를 지정할 수 있음
- 애플리케이션을 독립 실행형 태스크로 배포하는 것이 좋은 경우: 애플리케이션을 개발 중이지만 이것을 서비스 스케줄러를 사용하여 배포할 준비가 되어 있지 않다고 가정해 봅시다. 애플리케이션이 일회성이거나 계속 실행하거나 종료 시 재시작하는 것이 의미가 없는 주기적인 배치 작업인 경우가 여기에 속할 수 있습니다.

## ECS service
- 서비스를 생성하면서 여러개의 로드밸런서 혹은 로드밸런서의 여러 타겟그룹으로 트래픽을 보내려면 `aws cli` 등을 이용해야 하고 aws managed console에서는 작업이 되지 않는다.
- 아래 `core-apne2-querypie-app.json` 이용하여 생성하였음 명령어는 `aws ecs create-service --cli-input-json file://core-apne2-querypie-app.json`
```json
{
    "cluster": "querypie",
    "serviceName": "core-apne2-querypie-app",
    "taskDefinition": "querypie-app:5",
    "loadBalancers":[
        {  
           "targetGroupArn":"arn:aws:elasticloadbalancing:ap-northeast-2:433719637643:targetgroup/querypie-middleware-3000/c32247195202145d",
           "containerName":"querypie-app",
           "containerPort":3000
        },
        {  
           "targetGroupArn":"arn:aws:elasticloadbalancing:ap-northeast-2:433719637643:targetgroup/querypie-middleware-40000/4f20cc4926253364",
           "containerName":"querypie-app",
           "containerPort":40000
        },
        {  
           "targetGroupArn":"arn:aws:elasticloadbalancing:ap-northeast-2:433719637643:targetgroup/querypie-middleware-6000/7bfbd203de0450dd",
           "containerName":"querypie-app",
           "containerPort":6000
        },
        {  
           "targetGroupArn":"arn:aws:elasticloadbalancing:ap-northeast-2:433719637643:targetgroup/querypie-middleware-8000/636ef598ed869da6",
           "containerName":"querypie-app",
           "containerPort":8000
        },
        {  
           "targetGroupArn":"arn:aws:elasticloadbalancing:ap-northeast-2:433719637643:targetgroup/querypie-middleware-9000/0c3aba2cfe723d68",
           "containerName":"querypie-app",
           "containerPort":9000
        }
     ],
    "desiredCount": 1,
    "clientToken": "",
    "launchType": "FARGATE",
    "platformVersion": "LATEST",
    "role": "",
    "deploymentConfiguration": {
        "deploymentCircuitBreaker": {
            "enable": false,
            "rollback": false
        },
        "maximumPercent": 200,
        "minimumHealthyPercent": 100
    },
    "networkConfiguration": {
        "awsvpcConfiguration": {
            "subnets": [
                "subnet-0abf7b5558b8d43e0",
                "subnet-05f0c7d54ab2e75dd",
                "subnet-0ff2a2f37e88a1bab"
            ],
            "securityGroups": [
                "sg-062d81014b9034ec7",
                "sg-0b029e44266094f77"
            ],
            "assignPublicIp": "DISABLED"
        }
    },
    "healthCheckGracePeriodSeconds": 120,
    "schedulingStrategy": "REPLICA",
    "deploymentController": {
        "type": "ECS"
    },
    "tags": [
        {
            "key": "Name",
            "value": "core-apne2-querypie-app"
        }
    ],
    "enableECSManagedTags": true,
    "propagateTags": "TASK_DEFINITION",
    "enableExecuteCommand": true
}
```

## fargate 에 접속해서 컨테이너 상태 등 살펴보기
- AWS SSM Plugin이 Local PC에 설치되어 있어야 함, 참고: https://docs.aws.amazon.com/ko_kr/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
- ECS Task Role에 다음의 ssmmessage 권한 추가
```json
{
   "Version": "2012-10-17",
   "Statement": [
       {
       "Effect": "Allow",
       "Action": [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
       ],
      "Resource": "*"
      }
   ]
}
```
- 서비스를 배포할 때 `enableExecuteCommand`가 설정되어야 함.
<img width="309" alt="Screen Shot 2022-09-30 at 9 41 43 AM" src="https://user-images.githubusercontent.com/33619494/193165906-05e791b3-e1d1-4f73-bb46-0c32a2aaaeb9.png">
  - 코드 혹은 aws 매니지드 콘솔에서 서비스 배포 시 해당 설정 킬 수 있음

- fargate 접속
```bash
aws ecs execute-command --profile $PROFLE_NAME --region $REGION_NAME --cluster $CLUSTER_ARN \
  --task $TASK_ARN \
  --container $CONTAINER_NAME \
  --command "/bin/sh" \
  --interactive
```
- 접속원리는 아래와 같은 그림
![image](https://user-images.githubusercontent.com/33619494/193166305-8b6ba9a1-3f2d-44a6-9a65-9699e8691bf9.png)