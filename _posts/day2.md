## OKTA
- 옥타 설정방법 및 어떤 어플리케이션이 연동되어있는지 확인
- SSO로 Okta 서비스를 사용 중
- 지금은 AWS를 연동하고 있고, 추후 다른 서비스들(Slack, GitHub 등)도 추가 연동해서 모든 서비스 접근을 Okta 인증 하나로 통합할 계획

### Okta 어드민 설정
- Security > Administrators 메뉴에서 설정
- <img width="1004" alt="image" src="https://user-images.githubusercontent.com/33619494/190103784-afcf41cb-f657-452c-924b-6dc473f857e7.png">

### 인증 방식 설정
- Security > Authenticators 메뉴에서 설정합니다.
- Okta Verify > Actions > Edit > Verification options에 Push notification 옵션 Enable
- Add authenticator로 WebAuthn (FIDO2) 방식을 추가하면 맥북 지문 인증을 사용할 수 있어 편리함(Trial 버전은 없어서 유료 버전부터 지원되는 것으로 추측)
- 어드민이 WebAuthn Authenticators 방식 추가 후, 각 개인이 계정 설정에서 Okta setting > security key or biometric > Phone 과 This device(맥북) 추가 하면 맥북 지문 인증으로 2차 인증을 할 수 있음

### 유저 그룹 추가
- Directory > Groups 메뉴에서 설정
- 콘솔은 접근제어가 가능한데, `aws cli` 같은 것은 어떻게 제어할 것인가?
- Directory > Groups > Rules 에서 유저 그룹 할당 규칙을 지정하면 유저 attribute 등에 따라 자동으로 그룹에 유저를 할당할 수도 있음
- <img width="1001" alt="Screen Shot 2022-09-14 at 5 37 41 PM" src="https://user-images.githubusercontent.com/33619494/190104858-4b61a0f6-c854-427c-a3a2-ca3e5e0b282d.png">
- <img width="1022" alt="image" src="https://user-images.githubusercontent.com/33619494/190105396-e0891a75-fd5a-4745-b1fe-431b86d134ed.png">
- 위와같이 user attribute에 따라서 group에 자동으로 들어오게 할 수 있음

### 유저 추가
- Directory > People 메뉴에서 설정
- Add person을 통해 등록합니다. 
- 등록 시 Primary email 주소로 가입 메일이 발송되며 등록 된 유저가 mail에서 activate 하면 됨
- 이 후 Directory > Groups > `$그룹명` 에서 해당 그룹에 유저를 Assign할 수 있음

### AWS 어플리케이션 추가
- Okta 인증으로 AWS에 접근하기 위해 AWS 어플리케이션을 추가, 설정
- 어플리케이션 추가
    - Applications > Applications > Browse App Catalog
    - AWS IAM Identity Center 검색 후 선택 > Add Integration > Done
- 어플리케이션 설정
    - Applications 에 생성된 AWS IAM Identity Center(기본 이름) 설정에 들어가 아래 내용들 실행
    - AWS IAM Identity Center > `Sign On` 탭
       1. View SAML setup instructions 버튼을 눌러 메뉴얼을 따라 AWS IAM Identity Center 설정을 진행
       2. https://saml-doc.okta.com/SAML_Docs/How-to-Configure-SAML-2.0-for-AWS-Identity-Manager-Center.html?baseAdminUrl=https://greenlabsfinancial-admin.okta.com&app=amazon_aws_sso&instanceId=0oa243hgduTobKLaV697#steps 참고
    - AWS IAM Identity Center > `Provisioning` 탭
        1. To App > Provisioning to App > Edit 을 누른 뒤, Create Users, Update User Attributes, Deactivate Users 항목 전부 Enable 후 Save
        2. To Okta는 스킵
        3. (aws console)AWS IAM Identity Center > Settings > Identity source > Actions > Manage provisioning 에서 SCIM endpoint를 복사, Access token 생성 후 값 복사 (Access token은 기한이 1년이므로 1년 뒤 만료되면 재생성해서 Okta에 업데이트 해주어야 함)
        4. Integration > Edit 를 누른 뒤, 3. 에서 복사한 값들을 Base URL과 API Token에 기입하고 Test API Credentials 를 눌러 성공하면 Save
- 어플리케이션을 통해 Okta 유저와 그룹 AWS에 Sync하기
    - AWS IAM Identity Center > Assignments 탭
        1. Assign > Assign to Groups
        2. AWS에 생성할 그룹을 Assign 후 Done
        3. 팁: Assign to People은 사용하지 마세요. 유저 단위로 AWS에 할당하면 권한 부여 현황이 잘 보이지않아 관리가 힘듭니다. 한 두 유저만 예외적으로 할당하고 싶은 경우에도 가급적 AWS-임시-XXX 같은 이름으로 임시 그룹을 만들어 유저를 포함시킨 뒤 그룹으로 AWS에 할당하는 것이 좋습니다.
    - AWS IAM Identity Center > Push Groups 탭
        1. Assignments에서 그룹을 AWS 앱에 할당하는 것만으로는 해당 그룹과 유저들이 AWS에 생성되지 않음
        2. Push Groups > Find groups by *** 으로 AWS 앱에 할당된 그룹을 찾아 Create Group으로 Save
        3. 팁: 뭔가 잘 Sync가 되지 않으면, Provisioning 설정에서 Create, Update 설정이 켜져있는지 확인합니다. 그리고 Unlink pushed group > Delete the group in target app 으로 삭제한 뒤, Assignments부터 재진행해봅니다.
- AWS Identity Center에서 groups에 추가된 그룹 확인 가능

### AWS Identity Center
- core 계정 하나에서 작동하는 aws service
- SCIM을 통해 AWS API를 호출하여 관리하는 방식
- scim이 무엇인가?
- https://greenlabsfinancial-admin.okta.com/app/amazon_aws_sso/0oa243hgduTobKLaV697/setup/help/SAML_2_0/external-doc 참고

### 앞으로 익힐것들
- 테라폼 소스 코드 보기
- core 계정에 retool 띄워보기
- saml 이란 무엇인가?