---
layout: post
title: Go lang 개발환경 만들기 with vim-go
tags:
  - go
---
Go 언어를 이용한 개발 공부를 하기 위해 ubuntu 리눅스에 go를 설치하고 vim에서 편리하게 사용할 수 있도록 vim-go를 설치한 문서이다.

### Go lang 설치
- [다운로드](https://golang.org/dl/) 페이지에서 적합한 버전을 다운 받는다.
- 2019/5/30 최신 버전으로 `go1.12.5.linux-amd64.tar.gz`를 선택했다.
- 다운로드 받은 tar 파일의 압축을 `/usr/local`경로에 푼다.  
`sudo tar -C /usr/local -xzf go1.12.5.linux-amd64.tar.gz`
- `PATH`에서 `go`를 찾을 수 있게 업데이트 해준다.  
`echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc`
- `source ~/.bashrc`로 업데이트 해준다.
- 홈 디렉토리에 `go` 폴더를 생성한다.

### Vim-go 설치
- Vundle이용해서 설치한다.
- `~/.vimrc`에 `Plugin 'fatih/vim-go'`추가
- `vim` 커맨드로 vim 실행 후, `:PluginInstall` 명령으로 설치
- 이후, `*.go`로 끝나는 파일 작성하면 아래와 같이 기본적으로 필요한 양식이 포함되어 나타난다.

```go
package main
  
import "fmt"

func main() {
        fmt.Println("vim-go")
}
```
