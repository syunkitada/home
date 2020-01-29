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


## Setup
* [Downloads](https://golang.org/dl/)から、ダウンロードして展開する
```
$ git clone https://github.com/syndbg/goenv.git ~/.goenv

# .zshrc
export GOENV_ROOT=$HOME/.goenv
export PATH=$GOENV_ROOT/bin:$PATH
eval "$(goenv init -)"
export GO111MODULE=off

# check versions
$ goenv install -l

$ goenv install 1.12.15

$ goenv global 1.12.15

$ go version go1.12.15 linux/amd64
```


## Workspace design
* cmd
    * ファイル
* pkg
    * パッケージファイル
* src
    * ソースファイル


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


## Task Runner
* godoというTaskRunnerを利用すると、 ファイルが変更検知と再リロードを自動で行うことができるので便利
* [利用例](https://github.com/syunkitada/go-samples/tree/master/godo-sample)

* 以下のようにすると、開発はローカルで行って、ファイル変更を検知したらrsyncするなどもできる
* リモート側でもgodoを動かしておいて、複数のリモートに変更を反映させて再リロードするなどできる

```
package main

import (
    do "gopkg.in/godo.v2"
)

func tasks(p *do.Project) {
    p.Task("test", nil, func(c *do.Context) {
        c.Run("rsync -r --delete --exclude *hoge* hogeapp/ 192.168.1.1:go/src/github.com/piyo/hoge/")
    }).Src("hogeapp/**/*.{go}")
}

func main() {
    do.Godo(tasks)
}
```


## Vim environments
* vim-go
    * シンタックスハイライト
    * ファイル保存時にの自動フォーマット
    * Lintチェック
      * Lintチェックについては、若干処理が重くエディタ側の邪魔してしまうので別途Task Runnerに任せるのもあり
