---
layout: post
title: VIM과 YouCompleteMe 설치
tags:
  - vim
---

리눅스에 기본 텍스트 편집기로 vim이 존재한다. 진입장벽이 약간 높지만, 익히면 정말 편리하고 좋은 도구이다.  
코드 작성시 autocomplete 기능이 있으면 좋을 것 같아 `YouCompleteMe`를 설치했고 해당 과정을 적고자 한다.

### 설치조건
- VIM 버전 7.4.1578 이상, Python 2 혹은 Python 3 지원
  - 파이썬 지원 여부는 `vim` 실행하여 `:echo has('python') || has('python3')` 해당 커멘드가 1을 리턴하면 되는 것이다.
  - 우분투 처음 설치 후 `vim` 커맨드가 없어서 `apt`로 설치했다.

### VIM 설치
- `vim` 커맨드가 작동하지 않아 `vi`로 대신 살펴봐도 분명 `vim`이라고 뜬다.
- `apt list --installed | grep vim` 으로 설치된 패키지를 봐도 아래와 같이 분명 vim이 설치돼 있다.
```bash
vim-common/bionic,bionic,now 2:8.0.1453-1ubuntu1 all [installed]
vim-tiny/bionic,now 2:8.0.1453-1ubuntu1 amd64 [installed]
```
- 하지만 `vim` 커맨드를 치면 설치하라고 나온다??

```bash
Command 'vim' not found, but can be installed with:

sudo apt install vim
sudo apt install vim-gtk3
sudo apt install vim-tiny
sudo apt install neovim
sudo apt install vim-athena
sudo apt install vim-gtk
sudo apt install vim-nox
```

- 그래서 `sudo apt install vim -y` 명령으로 설치했다.

### Vundle 설치
- `Vundle`은 `vim`의 패키지 매니저이다.
> ubuntu 의 `apt` 혹은 centos의 `yum`같은 역할을 한다.
- 원활한 이용을 위해 `git`과 `curl`이 필요하다.  
`sudo apt install git curl -y`
- `git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim`
- 홈 디렉토리에 `.vimrc`파일을 만들고 아래 내용을 붙여넣기 한다.
```
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Below is example:
" Plugin 'tpope/vim-fugitive'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
```
- `:PluginInstall` 명령으로 설치한다.

### 설치환경
- Ubuntu 18.04
- VIM version: 8.0 (2016 Sep 12, compiled Apr 10 2018 21:31:58)
- Vundle 이용

### 설치절차
1. Vundle 이용해서 설치
- `~/.vimrc`에 `Plugin 'Valloric/YouCompleteMe'` 추가
- `vim` 커맨드로 vim 실행 후, `:PluginInstall` 명령으로 설치
- 플러그인이 설치 완료되면 하단에 붉은 경고 문구가 발생한다.  
`The ycmd server SHUT DOWN (restart with ':YcmRestartServer'). YCM core library not detected; you need to compile YCM before using it. Follow the instructions in the documentation.`
- 컴파일을 해야 한다.
2. 컴파일에 필요한 패키지 설치
- `sudo apt install build-essential cmake python3-dev -y`
3. python3로 컴파일
- 컴파일 하기 전 지원하는 언어들을 특정하여 컴파일 할 수 있다.
- 나의 경우 Go 언어 지원을 위해 `--go-completer` 플래그를 주었다.
- 다른 컴파일 옵션은 [공식문서](https://github.com/Valloric/YouCompleteMe#linux-64-bit)를 참고하자.
```bash
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --go-completer
```
