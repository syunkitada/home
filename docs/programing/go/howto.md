## How to


## Contents
| Link | Description |
| --- | --- |
| [はじめに](#はじめに)                       | |
| [Install packages](#install_packages)       | |
| [Export environments](#export_environments) | |
| [Workspace design](#workspace-design)       | |
| [How to develop](#how-to-develop)           | |
| [Vim environments](#vim-environments)       | |


## はじめに
* 公式がとても充実してるので、基本的にこれだけ見ておけばOK
    * https://golang.org/doc/
    * Goを始める前に最低限見るべきもの
        * [A Tour of Go](https://tour.golang.org/)
        * [How to write Go code](https://golang.org/doc/code.html)
    * Goに少しなれてきたら見るべきもの
        * [Effective Go](https://golang.org/doc/effective_go.html)
        * [Diagnostics](https://golang.org/doc/diagnostics.html)


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
    * workspaceのPATH
    * Go言語でパッケージをimportするときの解決先
    * go getやgo installをしたときのパッケージやバイナリのインストール先
* GOROOT
    * goのバイナリに含まれてるので、基本的に設定しなくて良い

> .zshrc
``` bash
export PATH=$PATH:/usr/local/go/bin
export PATH=${PATH}:/usr/local/go/bin:/${GOPATH}/bin
```


## Workspace design
* bin
    * 実行ファイル
* pkg
    * パッケージファイル
* src
    * ソースファイル
    
```
bin/
    hello                          # command executable
    outyet                         # command executable
pkg/
    linux_amd64/
        github.com/golang/example/
            stringutil.a           # package object
src/
    github.com/golang/example/
        .git/                      # Git repository metadata
    hello/
        hello.go               # command source
    outyet/
        main.go                # command source
        main_test.go           # test source
    stringutil/
        reverse.go             # package source
        reverse_test.go        # test source
    golang.org/x/image/
        .git/                      # Git repository metadata
    bmp/
        reader.go              # package source
        writer.go              # package source
    ... (many more repositories and packages omitted) ...
```


## How to develop
* 開発するときは、ワークスペースのsrcにディレクトリを切って行う

``` sh
$ mkdir -p $GOPATH/src/github.com/syunkitada/go-hello
$ cd $GOPATH/src/github.com/syunkitada/go-hello
```

* スクリプトを作成

``` sh
$ vim go-hello.go
```

> go-hello.go
``` go
package main

import "fmt"

func main() {
        fmt.Printf("Hello, world.\n")
}
```

* ローカルで、go buildすると、実行ファイルが作られるので実行を試せる

``` sh
$ go build

$ ./go-hello
Hello, world.
```

* go installをすると、$GOPATH/binに実行ファイルがインストールされる

```
$ go install

$ $GOPATH/bin/go-hello
Hello, world.
```

* go build, go installは、srcからの相対パスを指定すればどこからでも実行可能

```
$ go build github.com/syunkitada/go-hello
$ go install github.com/syunkitada/go-hello
```

* git管理しておくと、go getによってパッケージとしてダウンロードできるようになる

```
$ git init
Initialized empty Git repository in /home/user/work/src/github.com/user/hello/.git/
$ git add hello.go
$ git commit -m "initial commit"
$ git remote add origin git@github.com:syunkitada/go-hello.git
$ git push -u origin master

# ディレクトリを削除してgo getしてみる
$ cd $GOPATH
$ rm -rf src/github.com/syunkitada/go-hello/
$ go get github.com/syunkitada/go-hello
$ ls src/github.com/syunkitada/go-hello/
go-hello.go

$ go install github.com/syunkitada/go-hello
```

* 外部パッケージを利用する場合

> go-hello.go
``` go
package main

import (
    "net/http"

    "github.com/labstack/echo"
)

func main() {
    e := echo.New()
    e.GET("/", func(c echo.Context) error {
            return c.String(http.StatusOK, "Hello, World!")
    })
    e.Logger.Fatal(e.Start(":1323"))
}
```

* go getで依存パッケージをダウンロードすれば、build、installができるようになる

```
# srcに依存パッケージがないといけないのでそのままだと失敗する
$ go install github.com/syunkitada/go-hello
../src/github.com/syunkitada/go-hello/go-hello.go:6:2: cannot find package "github.com/labstack/echo" in any of:
        /usr/local/go/src/github.com/labstack/echo (from $GOROOT)
        /home/owner/go/src/github.com/labstack/echo (from $GOPATH)

# go getすると、依存のパッケージをすべてダウンロードしてくれる
$ go get github.com/syunkitada/go-hello

$ ls src/github.com/labstack/
echo/  gommon/

$ go install github.com/syunkitada/go-hello

$ $GOPATH/bin/go-hello
⇨ http server started on [::]:1323
...
```


## Package dependency management tool
* go getで、依存パッケージも一緒にcloneできるのだが、パッケージのバージョンを指定できないため、別途依存管理用のツールが必要になる
* 今までは、いくつかの候補があったが、公式がdepを出したのでこれで決定と思われる(2018/05/06時点では、まだOfficialではなくExperimental)
    * https://github.com/golang/dep
    * https://golang.github.io/dep/docs/introduction.html

``` sh
# Install into your $GOPATH/bin
$ curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

$ dep -h
Dep is a tool for managing dependencies for Go projects

Usage: "dep [command]"

Commands:

  init     Set up a new Go project, or migrate an existing one
  status   Report the status of the project's dependencies
  ensure   Ensure a dependency is safely vendored in the project
  prune    Pruning is now performed automatically by dep ensure.
  version  Show the dep version information

Examples:
  dep init                               set up a new project
  dep ensure                             install the project's dependencies
  dep ensure -update                     update the locked versions of all dependencies
  dep ensure -add github.com/pkg/errors  add a dependency to the project

Use "dep help [command]" for more information about a command.
```

* 利用例

```
$ mkdir -p $GOPATH/src/github.com/syunkitada/go-chi-sample
$ cd $GOPATH/src/github.com/syunkitada/go-chi-sample

$ ls
Gopkg.lock  Gopkg.toml  vendor/
```

* goファイルを作成する

```
$ vim server.go
cat server.go
package main

import (
        "github.com/go-chi/chi"
        "net/http"
)
...
```

* ensureを実行すると、自動的に.goのファイルを読んで、依存解決してくれる

```
$ dep ensure

# 確認
$ cat Gopkg.lock
# This file is autogenerated, do not edit; changes may be undone by the next 'dep ensure'.


[[projects]]
  name = "github.com/go-chi/chi"
  packages = ["."]
  revision = "e83ac2304db3c50cf03d96a2fcd39009d458bc35"
  version = "v3.3.2"


# vendorは消しても、dep ensureで作り直される(vendoerは、.gitignoreに書いておいて、開発時にdep ensureすれば良い)
$ rm -rf vendor
$ dep ensure
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
