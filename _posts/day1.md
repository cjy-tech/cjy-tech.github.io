## 출근 첫 날 파악한 것들과 앞으로 익힐것들
- 전체적인 폐쇄망 네트워크 연결은 아래와 같을 것으로 추정
- ![폐쇄망 (1)](https://user-images.githubusercontent.com/33619494/189910812-3f88cfdf-0f49-42e1-a6ef-86c63a076a0d.jpg)
- 구성 방법은 링크와 비슷할 것으로 추정: https://docs.aws.amazon.com/vpn/latest/s2svpn/SetUpVPNConnections.html

### UTM
- UTM(Unified Threat Management)
- 방화벽(Firewall), 가상 전용 네트워크(VPN), 침입 차단 시스템(IPS/IDS), 웹 컨텐츠 필터링(URL Filters),안티스팸 소프트웨어(Anti-SPAM) 등을 포함하는 여러 개의 보안 도구를 이용한 관리 시스템
- ![image](https://user-images.githubusercontent.com/33619494/189895662-d267d298-5a17-4560-a922-c66401fe8559.png)
- master / slave 구조
- utm 에 연결하면 dhcp로 172 대역의 프라이빗 ip를 할당해줌
- ![image](https://user-images.githubusercontent.com/33619494/190330742-1458e92c-66f3-44ef-8743-8ba52116ec05.png)

### Transit Gateway
- Transit Gateway는 Virtual Private Cloud(VPC)와 온프레미스 네트워크 간의 트래픽에 대한 리전별 가상 라우터 역할
- Transit Gateway의 연결로 Site-to-Site VPN 연결을 생성할 수 있음
- Transit Gateway의 Site-to-Site VPN 연결은 VPN 터널 내에서 IPv4 트래픽 또는 IPv6 트래픽을 지원할 수 있음
- 각 VPC의 라우팅 테이블에는 다른 VPC를 대상으로 하는 트래픽을 Transit Gateway로 보내는 로컬 경로가 포함
- ![image](https://user-images.githubusercontent.com/33619494/189897262-bc9a09af-15b2-48b0-8290-6f981c99302a.png)
- 라우팅 테이블
- ![Screen Shot 2022-09-13 at 9 10 37 PM](https://user-images.githubusercontent.com/33619494/189897435-673f9c6b-2c3d-4f0b-89b9-0911179e2947.png)
- 아래는 내가 생각하는 그린랩스 파이낸셜의 폐쇄망 구조인데 transit gateway는 어느 계정의 어느 vpc의 어느 서브넷에 할당되는가?: core 계정
- ![폐쇄망 (1)](https://user-images.githubusercontent.com/33619494/189910812-3f88cfdf-0f49-42e1-a6ef-86c63a076a0d.jpg)

### Site-to-Site VPN
- ![image](https://user-images.githubusercontent.com/33619494/189900249-7081cdf6-eed0-49dd-ac65-902c846e8492.png)
- Transit Gateway와 연결되는 Site-to-Site VPN은 어느 계정에 구성되어 있는가?: core 계정
- Transit Gateway와 UTM 장비간의 터널링 연결을 VPN 으로 칭한다.

### 앞으로 익힐것들
- 사내에서 utm 장비에 연결되면 폐쇄망으로만 접근되고 인터넷은 되지 않아야 하는 요구사항이 있음, 요구사항이 정확하다면 fortigate쪽에 문의해보기
- utm 접근제어
  - utm 로그인 계정에 대한 trusted host(ip기반) 설정
  - site to site vpn 리소스의 원격 IPv4 네트워크 CIDR 를 0.0.0.0이 아닌 제한을 둬야 한다.
  - utm 자체도 웹 브라우저에 들어올려면 폐쇄망 ip 대역으로 제한해야 하는지
  - utm 계정을 개인별로 두는게 맞는지?