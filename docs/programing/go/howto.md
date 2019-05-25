## How to


## Contents
| Link | Description |
| --- | --- |
| [はじめに](#はじめに)                                                     | |
| [Install packages](#install_packages)                                     | |
| [Export environments](#export_environments)                               | |
| [Workspace design](#workspace-design)                                     | |
| [How to develop](#how-to-develop)                                         | |
| [Package dependency management tool](#Package-dependency-management-tool) | |
| [Task Runner](#Task-Runner)                                               | |
| [Vim environments](#vim-environments)                                     | |


## はじめに
* Go初めての人は、公式がとても充実してるので基本的にこれだけ見ておけばOK
    * https://golang.org/doc/
    * Goを始める前に最低限見るべきもの
        * [A Tour of Go](https://tour.golang.org/)
        * [How to write Go code](https://golang.org/doc/code.html)
    * Goに少しなれてきたら見るべきもの
        * [Effective Go](https://golang.org/doc/effective_go.html)
        * [Diagnostics](https://golang.org/doc/diagnostics.html)
* 追加で学習するとよいこと
    * goroutine, channelまわりの実装
      * [Go の channel 処理パターン集](https://hori-ryota.com/blog/golang-channel-pattern/)
    * プロファイリング、goroutineによるメモリリークについて
      * [goで書いたコードがヒープ割り当てになるかを確認する方法](https://hnakamur.github.io/blog/2018/01/30/go-heap-allocations/)
      * [Allocation efficiency in high-performance Go services](https://segment.com/blog/allocation-efficiency-in-high-performance-go-services/)
      * [Go 言語のプロファイル機能とネットワークコネクションにまつわるトラブルシューティング](https://techblog.yahoo.co.jp/programming/troubleshooting-many-connections/)


## Install packages
* [Downloads](https://golang.org/dl/)から、ダウンロードして展開する
```
$ wget https://dl.google.com/go/go1.12.5.linux-amd64.tar.gz
$ sudo tar -C /usr/local -xzf go1.12.5.linux-amd64.tar.gz
```

* その他依存ツールもインストールしておく
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
export GO111MODULE=on
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
* goで依存パッケージを管理する場合、go getで依存パッケージも一緒にcloneできるが、パッケージのバージョンを指定できないため、別途依存管理用のツールが必要になる
* goでは、$GOPATH/src/プロジェクト/vendorが存在する場合、そこを優先して見てくれる
* このため、パッケージ管理用のサードパーティツールでは、このvendorに依存パッケージをダウンロードして管理している
* 2017年頃、サードパーティツールが乱立してきたところで、に公式から実験的なツールとしてdepが登場した
  * https://github.com/golang/dep
  * https://golang.github.io/dep/docs/introduction.html
* 2018年頃、go1.11でgomoduleが導入された
* 特にこだわりがなければgomoduleを利用すれば良さそう

### gomodule

```
# gomoduleの有効化
export GO111MODULE=on

# プロジェクトの初期化
# プロジェクトのルートディレクトリで以下を実行する
# すでにdepを使っていて、Gopkg.lockがあればそれを引き継いでgo.modを作成してくれる
$ go mod init

$ cat go.mod
module github.com/syunkitada/goapp

go 1.12

require (
        github.com/BurntSushi/toml v0.3.1
        github.com/MichaelTJones/walk v0.0.0-20161122175330-4748e29d5718 // indirect
        github.com/alecthomas/gometalinter v3.0.0+incompatible // indirect
        github.com/davidrjenni/reftools v0.0.0-20190411195930-981bbac422f8 // indirect
...

# 依存パッケージはrunやbuild時に、自動で$GOPATH/pkg/mod/にダウンロードされる
$ ls $GOPATH/pkg/mod/
9fans.net/  cloud.google.com/  golang.org/         gopkg.in/   mvdan.cc/
cache/      github.com/        google.golang.org/  honnef.co/  sourcegraph.com/
```

### dep

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


## Task Runner
* godoというTaskRunnerを利用すると、 ファイルが変更検知と再リロードを自動で行うことができるので便利
* [利用例](https://github.com/syunkitada/go-samples/tree/master/godo-sample)


## Vim environments
* vim-go
    * シンタックスハイライト
    * ファイル保存時にの自動フォーマット
    * Lintチェック
      * Lintチェックについては、若干処理が重くエディタ側の邪魔してしまうので別途Task Runnerに任せるのもあり
