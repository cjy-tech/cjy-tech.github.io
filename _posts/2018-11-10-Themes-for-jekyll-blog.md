---
layout: post
title: Jekyll 테마로 Blog 꾸미기
tags:
  - jekyll
  - github_pages
---

본격적으로 Blog를 관리하기 위해 예쁘게 꾸미고 나서 컨텐츠를 올리고 싶었다.  
인터넷에는 Jekyll에서 사용할 수 있는 많은 theme들이 있고, 이 페이지는 해당 내용을 적용한 방법이다.

### 테마 기본값 확인하기
자신의 컴퓨터에서 테마파일의 위치를 찾으려면 `bundle show $THEME_NAME`을 입력하면된다.  
나의 경우, Jekyll 기본 테마를 이용하였고 그 이름은 `minima`이기 때문에 아래 명령을 실행하였다.
```bash
bundle show minima
```
상기 명령은 Ruby gem 기반 테마 디렉토리의 위치를 보여준다. 해당 디렉토리의 구조를 확인해 보자.
```bash
tree /var/lib/gems/2.3.0/gems/minima-2.5.0

/var/lib/gems/2.3.0/gems/minima-2.5.0
|-- LICENSE.txt
|-- README.md
|-- _includes
|   |-- disqus_comments.html
|   |-- footer.html
|   |-- google-analytics.html
|   |-- head.html
|   |-- header.html
|   |-- icon-github.html
|   |-- icon-github.svg
|   |-- icon-twitter.html
|   |-- icon-twitter.svg
|   `-- social.html
|-- _layouts
|   |-- default.html
|   |-- home.html
|   |-- page.html
|   `-- post.html
|-- _sass
|   |-- minima
|   |   |-- _base.scss
|   |   |-- _layout.scss
|   |   `-- _syntax-highlighting.scss
|   `-- minima.scss
`-- assets
    |-- main.scss
    `-- minima-social-icons.svg
```
Jekyll 은 기본 디렉토리에 있는 테마의 기본 파일들을 확인하기 전에 사이트의 컨텐츠를 먼저 확인한다.  
나의 경우 GitHub Pages로 블로그를 호스팅했으므로 `cjy-tech.github.io` 디렉토리에 아래와 같은 폴더들이 있다면 그것들이 기본 테마를 덮어쓴다.  
`/assets`  
`/_layouts`  
`/_includes`  
`/_sass`  
당연히, 나의 레포지토리 디렉토리는 기본 설정이기 때문에 상기 폴더들이 존재하지 않는다.
```
.
|-- 404.html
|-- Gemfile
|-- Gemfile.lock
|-- README.md
|-- _config.yml
|-- _posts
|   `-- 2019-05-27-welcome-to-jekyll.markdown
|-- about.md
`-- index.md
```

### 맘에 드는 테마 선정하기
[Jekyll Theme](http://jekyllthemes.org/)에도 올라와 있고, 구글링 해 보면 수 많은 테마가 있다.  
나는 [친절한 레퍼런스](https://blog.naver.com/PostView.nhn?blogId=prt1004dms&logNo=221439087865)가 있는 [jekyll-now](https://github.com/barryclark/jekyll-now)테마를 사용하기로 했다.

### 테마 변경하기
1. Jekyll Now Repository Clone
  * 나의 블로그 레포지토리 이름으로 받아오기 위해 원래 디렉토리는 삭제하고 jekyll-now 테마를 받는다.
```bash
git clone git@github.com:barryclark/jekyll-now.git cjy-tech.github.io --depth 1
```
  * 내용을 확인해보면  
`/_layouts`  
`/_includes`  
`/_sass`  
  * 들을 비롯한 여러 내용이 추가된 게 확인된다.
  * 이제 앞서 확인한 Ruby gem 기반 테마 디렉토리의 내용 대신 이 레포지토리의 내용이 사용되는 것이다.
2. Remote Host Change
  * 클로닝을 내 블로그 이름으로 하였지만 여기서 수정사항을 반영하려면 원격지 정보를 내 블로그 레포지토리로 바꿔줘야 한다.
  * 현재는 아래와 같이 그냥 원조 Jekyll Now 레포지토리를 향하게 되어 있다.
```
git remote -v
origin  git@github.com:barryclark/jekyll-now.git (fetch)
origin  git@github.com:barryclark/jekyll-now.git (push)
```
  * `.git`디렉토리를 삭제하고 다시 만든다.
```
git init
git remote add origin https://github.com/cjy-tech/cjy-tech.github.io.git
```
  * 다시 확인해보면 아래와 같이 바뀌어 있다.
```
origin  https://github.com/cjy-tech/cjy-tech.github.io.git (fetch)
origin  https://github.com/cjy-tech/cjy-tech.github.io.git (push)
```
3.  `_config.yml`수정
  * 6라인과 9라인의 `name`, `description`을 수정한다.
```yml
  6 name: JunYoung's Blog
  7
  8 # Short bio or description (displayed in the header)
  9 description: DevOps WannaBe
```
4. 테스트
  * 수정사항을 나의 레포지토리에 push하여 확인해보자.
  * https://cjy-tech.github.io 주소로 접속하면 이전과는 다른 테마가 적용된 블로그가 표시된다!
  ![image](https://user-images.githubusercontent.com/33619494/58419355-571de380-80c5-11e9-9c7b-e6e30336b7f9.png)
