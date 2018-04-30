# Go


## Install packages
* [Downloads](https://golang.org/dl/)から、ダウンロードして展開する
```
$ wget https://dl.google.com/go/go1.10.1.linux-amd64.tar.gz
$ sudo tar -C /usr/local -xzf go1.10.1.linux-amd64.tar.gz
```

* その他必須ツールもインストールしておく
``` bash
# for ubuntu
$ sudo apt-get install git mercurial
```


## Export environments
* 以下の環境変数を.zshrcなどで設定しておく
* PATH
    * go/binを追加して、goを実行できるようにする
* GOPATH
    * Go言語でパッケージをimportするときの解決先
    * go getやgo installをしたときのパッケージやバイナリのインストール先
* GOROOT
    * goのバイナリに含まれてるので、基本的に設定しなくて良い

> .zshrc
``` bash
export PATH=$PATH:/usr/local/go/bin
export GOPATH=${HOME}/go
```


## Vim environments
* vim-go
    * シンタックスハイライト
    * ファイル保存時にgo fmtが実行され、コードが自動整形される

> dein_lazy.toml
```
[[plugins]]
repo  = 'https://github.com/fatih/vim-go.git'
rev = 'v1.15'
on_ft = ['go']
```

> .vimrc
```
" For golang
" vim-go
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
```

* vim-goの初期設定として、vim起動後に以下のコマンドを実行して、vim-goが依存してるパッケージをインストールする
> vim
```
:GoInstallBinaries
```


## Hello world
```
$ mkdir -p $HOME/go/src/helloworld
$ cd go/src/helloworld

$ vim hello.go
package main

import "fmt"

func main() {
    fmt.Printf("Hello, world.\n")
}

$ go build

$ ls
hello*  hello.go

$ ./hello
hello, world
```
