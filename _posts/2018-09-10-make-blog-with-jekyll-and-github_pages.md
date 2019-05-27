---
layout: post
title: 개인 Blog 만드는 절차 with Jekyll & GitHub Pages
tags:
  - jekyll
  - github_pages
---

### 선행 조건

1. Ruby 설치
Ubuntu 운영체제 이므로 `apt`패키지관리자로 설치한다.
```bash
sudo apt-get install ruby-full -y
```
다른 설치 방법은 [참고](https://www.ruby-lang.org/ko/documentation/installation/).

2. Jekyll, Bundler설치
`gem`이라는 Ruby의 패키지 관리자를 사용해서 `jekyll`과 `bundler`설치
```bash
sudo gem install jekyll bundler
```
### Jekyll 테스트

1. 블로그 디렉토리 생성
아래 명령으로 `jekyll`로 블로그 디렉토리를 생성한다. `$NAME`은 생성하고자 하는 디렉토리 이름으로 변경한다. 나는 test로 명하였다.
```bash
jekyll new $NAME
```
상기 명령을 실행한 위치에 `test`라는 디렉토리가 생성되었고 그 디렉토리의 구조는 아래와 같다.
```
.
|-- 404.html
|-- Gemfile
|-- Gemfile.lock
|-- _config.yml
|-- _posts
|   `-- 2019-05-27-welcome-to-jekyll.markdown
|-- about.md
`-- index.md
```
2. 로컬에서 서버 띄우기
상기 파일들로 이루어진 블로그를 실행해본다. `Gemfile`이 위치한 `test`디렉토리에서 아래 명령을 실행한다.
```bash
bundle exec jekyll serve
```
로그가 출력된다.
```
Configuration file: /home/cjy/test/_config.yml
            Source: /home/cjy/test
       Destination: /home/cjy/test/_site
 Incremental build: disabled. Enable with --incremental
      Generating...
       Jekyll Feed: Generating feed for posts
                    done in 0.734 seconds.
 Auto-regeneration: enabled for '/home/cjy/test'
    Server address: http://127.0.0.1:4000/
  Server running... press ctrl-c to stop.
```
3. 접속 테스트
상기 로그에 나온대로 http://127.0.0.1:4000 에 접속하여 테스트 블로그가 잘 나오는지 확인한다.
![image](https://user-images.githubusercontent.com/33619494/58391842-51e37900-8072-11e9-82ce-284be7e55f2d.png)

### GitHub Pages 생성
자신의 서버에서 확인하였으니, 이제 온라인으로 다른 곳에서도 접속하여 확인 할 수 있는 진짜 블로그를 만들어 보겠다.
블로그를 만들기 위한 도구는 GitHub Pages를 이용할 것이다.
1. GitHub Pages로 repository 생성
[GitHub](https://github.com/)에 접속하여 새로운 Repository를 생성한다.
![image](https://user-images.githubusercontent.com/33619494/58393109-13e95380-8078-11e9-8f7c-4c2dd7909b68.png)
상기 이미지 표시처럼 New버튼을 [클릭](https://github.com/new)하면
Create a new repository 화면으로 넘어간다.
![image](https://user-images.githubusercontent.com/33619494/58393174-67f43800-8078-11e9-9a20-9e5d80d9914e.png)
Repository name에 자신의 GitHub username을 적고 `.github.io`를 붙여준다. 여기서 자신의 username 대신에 다른 것을 적으면 작동하지 않는다.
![image](https://user-images.githubusercontent.com/33619494/58393422-9aeafb80-8079-11e9-9ad4-c03cc6624c96.png)
하지만 나는 luckymagic7이라는 username 대신 다른 이름을 사용하고 싶었기 때문에, organization을 새로 만들고 그 이름을 사용하였다.

2. GitHub Pages 테스트
생성한 repository를 clone 받고 진입하여 아래 명령을 차례대로 실행한다.
```bash
echo "Hello World" > index.html
git add --all
git commit -m "Initial commit"
git push -u origin master
```
master 브랜치에 push가 완료되면 `$REPOSITORY_NAME.github.io`로 접속하여 Hello World가 표시되는지 확인한다.
![image](https://user-images.githubusercontent.com/33619494/58393797-4779ad00-807b-11e9-837c-a612af4aee88.png)

### Jekyll과 GitHub Pages 연동
Hello World는 심플하고 이젠 지겹다. 이전에 로컬에서 띄운 내용으로 대체하겠다.
clone 한 git디렉토리의 한 단계 위로 이동하여 아래 명령을 실행한다.
```bash
jekyll new $REPOSITORY_NAME.github.io -f
```
`-f`flag는 `--force`의 약자로 해당 디렉토리가 비어 있지 않기 때문에 주는 옵션이다. 만약 생략한다면 아래와 같은 에러가 발생한다.
```
jekyll new cjy-tech.github.io
          Conflict: /home/cjy/git/cjy-tech.github.io exists and is not empty.
                    Ensure /home/cjy/git/cjy-tech.github.io is empty or else try again with `--force` to proceed and overwrite any files.
```
다시 레포지토리로 들어가 변경 사항들을 확인하고 commit하여 master 브랜치에 push 하자.
이후 `$REPOSITORY_NAME.github.io`로 접속하면 윗부분의 Jekyll로 띄운 블로그의 내용이 확인된다.
![image](https://user-images.githubusercontent.com/33619494/58391842-51e37900-8072-11e9-82ce-284be7e55f2d.png)

### 결론
- 원격지에서 접속 할 수 있는 블로그를 호스팅하기 위해 GitHub Pages를 이용한다.
-  Jekyll을 이용해 Markdown 문서를 GitHub Pages에서 보여주는 HTML 양식으로 바꿔준다.

### 더 해보기
- 블로그를 꾸미기 위해서는 다양한 [Jekyll테마를 적용]() 할 수 있다.
- [Markdown 컨텐츠를 이용하여 본격적으로 블로그 포스팅]()을 해 보자.
- 블로그 내용의 댓글 추가를 위해 [Disqus를 적용]() 해 보자.
