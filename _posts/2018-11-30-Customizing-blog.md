---
layout: post
title: Favicon 및 Disqus 댓글 설정
tags:
  - jekyll
  - github_pages
  - disqus
  - favicon
---

### Favicon?

![image](https://user-images.githubusercontent.com/33619494/58427169-cdc4dc00-80d9-11e9-8c3e-c84912407b6b.png)

Favicon의 정의는 다음과 같다
> 인터넷 웹 브라우저의 주소창에 표시되는 웹사이트나 웹페이지를 대표하는 아이콘이다

### Favicon 적응기

1. 소스 아이콘 검색
  * 무료 아이콘들이 많은 [사이트](https://icons8.com/icons)에서 맘에 드는 아이콘을 골라서 다운로드 한다.
2. Favicon 생성
![image](https://user-images.githubusercontent.com/33619494/58427374-5cd1f400-80da-11e9-9b32-21c37028f61e.png)
  * Favicon을 생성해주는 [사이트](https://icons8.com/icons)에 접속하여 다운로드 받은 파일을 업로드 하고, Create Favicon을 선택한다.
![image](https://user-images.githubusercontent.com/33619494/58427444-9a368180-80da-11e9-9f4f-f0fe2509a750.png)
  * 생성한 favicon을 다운로드 하고 하단의 `HTML` 코드도 복사한다.
  * 코드를 보면 브라우저 별로 지정해주는 내용인 것 같다.
3. Favicon 업로드
  * 블로그의 루트 디렉토리에 `assets/logo.ico`디렉토리를 생성한다.
```bash
mkdir -p assets/logo.ico
```
![image](https://user-images.githubusercontent.com/33619494/58427650-382a4c00-80db-11e9-809a-f91b7d945261.png)
  * 해당 디렉토리에 다운로드 받은 favicon `ZIP`파일의 압축을 푼다.
4. `_includes/head.html` 수정
  * 2번에서 복사한 `HTML` 내용을  `_includes/head.html` 파일에 붙여넣기 한다.
  * link rel="apple-touch-icon" sizes="57x57" <mark>href</mark>="/apple-icon-57x57.png"
  * 이 때, href 부분에 favicon이 있는 경로를 적어야 한다. 아래와 같이 수정한다.
  * link rel="apple-touch-icon" sizes="57x57" <mark>href="{{site.baseurl}}/assets/logo.ico</mark>/apple-icon-57x57.png"
5. 확인
  * 변경내용을 commit 하고 push 하고 브라우저를 통해 접속해 보자.
  * 아래와 같은 logo가 추가되었다!  
  ![image](https://user-images.githubusercontent.com/33619494/58428006-3d3bcb00-80dc-11e9-9493-ef6c7cc91e68.png)

### Disqus

Jekyll은 정적 웹 호스팅이기 때문에 댓글 기능을 지원하지 않는다. Disqus를 이용하면 댓글 기능을 추가 할 수 있다.

1. Disqus 계정 생성
  * https://disqus.com/ 에서 계정을 생성하고 로그인한다.
2. 설정
![image](https://user-images.githubusercontent.com/33619494/58428282-f6020a00-80dc-11e9-807b-087429432750.png)
  * GET STARTED - I want to install Disqus on my site 클릭
![image](https://user-images.githubusercontent.com/33619494/58428370-319cd400-80dd-11e9-8ffc-67cfe921b2ab.png)
  * Website Name, Category, Language를 설정해준다.
  * Website Name은 이후 jekyll 테마 `_config.yml`에 추가된다.
  ```yml
  disqus: cjy-tech
  ```
3. 언어 설정
  * 분명 다른 레퍼런스들은 언어에 Korean이 있는데 나는 안 보인다.
  * 찾아보니 꼼수를 이용한 방법이 있다.
  * 브라우저의 개발자 도구를 연다. `Ctrl + F`로 Japanese를 검색한다.
  * 해당 라인에서 F2를 눌러 편집을 하고 아래 이미지 처럼 한줄 추가한다.
  ![image](https://user-images.githubusercontent.com/33619494/58428754-7f660c00-80de-11e9-9fbe-8286512436d8.png)
  ![image](https://user-images.githubusercontent.com/33619494/58428810-ac1a2380-80de-11e9-8069-7297feac0443.png)
4. 셋팅
  * 언어 설정까지 마친 후, Create Site를 눌러 다음으로 진행하고 요금제를 선택한다.
  * 보통 무료를 선택하겠지만, 개인의 취향껏 선택하고 다음 화면으로 넘어간다.
  ![image](https://user-images.githubusercontent.com/33619494/58428934-0f0bba80-80df-11e9-9791-08e057c7e106.png)
5. 확인
  * 상기 2번 과정에서 `_config.yml`파일을 수정하였으니 그대로 commit하고 push한다.
  * 이후 블로그에 댓글 기능이 추가된 것을 확인 할 수 있다.
  ![image](https://user-images.githubusercontent.com/33619494/58428991-44180d00-80df-11e9-8e9a-de98d44cc752.png)
