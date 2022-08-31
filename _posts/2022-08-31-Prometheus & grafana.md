## Prometheus
- Prometheus 2012년에 처음으로 모습을 드러낸 오픈소스 모니터링 플랫폼입니다.
- 기존의 다른 모니터링 플랫폼과는 다르게 Pull 방식을 사용하며, 각 모니터링 대상의 Exporter 또는 Prometheus client를 통해서 지표를 긁어가는(scrape) 방식으로 데이터를 수집합니다.
- 또한, CNCF(Cloud Native Computing Foundation)의 Graduated 프로젝트가 되어 현재 컨테이너 모니터링의 사실상 표준처럼 사용되고 있습니다.

### Install
- 이 문서에서는 컨테이너 환경이 아닌 on-promise 환경을 기준으로 하겠습니다.
- 아래의 페이지를 통해서 다운로드 받을 수 있습니다.

https://prometheus.io/download/


### Run
```bash
cd prometheus-2.17.1.linux-amd64
./prometheus
```
- 기본적으로 설정 파일은 같은 디렉토리 내의 prometheus.yml을 사용하며 포트는 9090사용합니다.
- 브라우저를 통해서 localhost:9090에 접근하면 아래와 같은 Prometheus 웹 화면이 보일 것입니다.
![image](https://user-images.githubusercontent.com/33619494/187583861-3f99bbd0-6a1d-4644-963c-71e2e994af73.png)
- 이 웹 화면에서 Prometheus의 조회 쿼리를 테스트해볼 수 있고 추가적인 설정을 통해서 지표 기록 및 알림 상태 등을 확인할 수 있습니다.

## Grafana
- 일반적으로 Grafana에서 말하는 데이터소스는 실제 시계열 지표 성격의 데이터를 저장하고 조회할 수 있는 플랫폼들을 말합니다.
- 현재 official로 지원하는 데이터소스는 Graphite, Prometheus, InfluxDB, Elasticsearch, AWS CloudWatch, OpenTSDB... 등으로 사실상 많이 사용되고 있는 대부분의 스토리지는 지원한다고 볼 수 있습니다.
- official 데이터소스가 아니더라도 다른 사용자가 제작한 데이터소스 플러그인을 사용할 수도 있기에 지원범위가 매우 넓습니다.
- Prometheus 데이터소스는 위에서 언급한대로 Grafana의 official 데이터소스 중 하나이기 때문에 Grafana에 기본적으로 built-in되어있어 저희가 별도로 설치해야할 것은 없습니다.

### Install
- 아래의 페이지에서 Grafana 바이너리와 각 운영체제 및 설치 방법에 따른 가이드가 제공되고 있습니다.

https://grafana.com/grafana/download

### Run
- standalone으로 실행한다면 별다른 설정이 필요하지 않습니다.
- 물론, 고가용성 또는 보안(인증, 권한 등)이 필요하거나 많은 트레픽을 처리해야하는 경우 별도의 설정이 필요할 것입니다.
```bash
cd grafana-6.7.2
./bin/grafana-server
```
- Grafana 웹서버의 기본 포트는 3000입니다.
- 브라우저를 통해서 http://localhost:3000으로 접속하면 Grafana 로그인 페이지가 보일 것 입니다.
![image](https://user-images.githubusercontent.com/33619494/187584199-ccb70ffd-5cb7-4cb6-8ca8-c091d2bbc313.png)

### Add Prometheus Data Source
- 상단의 `Add data source` 버튼을 클릭하거나 왼쪽 사이드메뉴의 `Configuration > Data sources > Add data source` 버튼을 클릭하여 데이터소스를 추가할 수 있습니다.
![image](https://user-images.githubusercontent.com/33619494/187584288-c3232410-5697-44f3-a6f5-d20fc6971b93.png)
- `Time series databases` 탭에서 `Prometheus` 선택합니다.
![image](https://user-images.githubusercontent.com/33619494/187584437-388ef9c8-8371-498e-b340-35681c6cb508.png)
- 원하는 이름으로 `Name` 필드를 작성하고 아래 HTTP 탭의 `URL` 필드에서는 조금 전에 설치하여 실행한 Prometheus의 URL을 입력합니다.
- Grafana와 Prometheus를 같은 호스트에 설치하였다면 http://lcoalhost:9090을 입력하면 될 겁니다.
- 값을 입력하고 아래의 `Save & Test` 버튼을 클릭하여 데이터소스를 저장합니다.
- 입력한 설정 값에 문제가 없다면 Success라는 녹색창의 메시지가 노출됩니다.
![image](https://user-images.githubusercontent.com/33619494/187584594-eea9f3f7-7dbc-433c-ac4d-f59ae712e1c4.png)

## Add Dashboard

### Marketplace
- Grafana 마켓플레이스에서 원하는 대시보드를 검색 및 import
  - https://grafana.com/grafana/dashboards?dataSource=prometheus&direction=asc&orderBy=name
- 마음에 드는 대시보드가 없다면 export된 다른 사람의 JSON 파일을 다운로드 받거나 직섭 대시보드를 생성

### 직접 그래프 추가
- 각 대시보드는 변수를 추가해서 사용 가능
- `my dashboard -> Setting -> Variables`에서 설정
- PromQL 내에서 `$variable_name` 같은 형태로 사용 가능
- PromQL(Prometheus Query Language)를 통해서 직접 지표를 가공 및 조회할 수 있음
  - PromQL 예제
    - 특정 서비스내 인스턴스의 API별 초 당 요청 수 조회
    `irate(http_server_requests_seconds_count{application="$application", instance="$instance"}[3m])`
    - 특정 서비스의 초 당 에러 요청 수 합계 조회
    `sum by (application) (irate(http_server_requests_seconds_count{application="$application", outcome=~"CLIENT_ERROR|SERVER_ERROR"}[3m]))`
- 조회 결과 시리즈 데이터의 레이블은 범례 이름으로 사용 가능. `{{ label_name }}`과 같은 형태로 레이블 지정
![image](https://user-images.githubusercontent.com/33619494/187590971-6499670a-f6cf-498e-a652-6e38183079ed.png)

## PromQL로 지표 조회하기
- Prometheus는 지표를 조회하기 위한 PromQL(Prometheus Query Language)이라는 쿼리 언어를 제공하고 있습니다.
- SQL처럼 수집된 지표를 필터링 및 집계할 수 있으며, 또한, 가공하고 알림을 발생시키는데 사용할 수 있습니다.
- 그리고 중요한 점은 Prometheus의 모니터링 대상이 expose하는 지표 데이터는 이전 수집 시기로부터의 변화량이 아니라 앱 실행시부터 누적된 값입니다(gauge 타입 제외).
- 지표의 변화량은 서버에서 조회시 PromQL을 통해서 계산할 수 있으며, rate, irate 같은 함수가 그 역할을 수행합니다.