## AWS Network Firewall​를 구성하는 resources
- firewall: VPC안의 subnet에서 들어오고 나가는 트래픽을 필터링하는 데 사용할 방화벽 자체
- firewall policy: 방화벽에 대한 규칙 및 기타 설정을 정의
- rule group: VPC 트래픽과 일치시킬 일련의 규칙을 정의하고, 네트워크 방화벽이 일치 항목을 찾을 때 수행할 작업을 정의

## firewall manager를 이용한 중앙 관리형 firewall
- aws config 사용 필요
  - NetworkFirewall FirewallPolicy, NetworkFirewall RuleGroup, EC2 VPC, EC2 InternetGateway, EC2 RouteTable, and EC2 Subnet 이 리소스들만 enable 하면 됨

## 10/11에 안됐던 이유
- 사무실 IP를 막아서 안 됐음...
- 핫스팟으로 검증 완료

## aws config?
- config에서 사용하는 버킷 policy에 정책 적용 필요
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSConfigBucketPermissionsCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::config-bucket-433719637643",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceAccount": [
                        "433719637643",
                        "366853022100"
                    ]
                }
            }
        },
        {
            "Sid": "AWSConfigBucketExistenceCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::config-bucket-433719637643",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceAccount": [
                        "433719637643",
                        "366853022100"
                    ]
                }
            }
        },
        {
            "Sid": "AWSConfigBucketDelivery",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::config-bucket-433719637643/AWSLogs/433719637643/Config/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control",
                    "AWS:SourceAccount": [
                        "433719637643",
                        "366853022100"
                    ]
                }
            }
        }
    ]
}
```