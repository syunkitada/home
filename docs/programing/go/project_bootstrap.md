# Project Bootstrap


## Project Tree
```
cmd/
    ...
pkg/
    ...
src/
    github.com/[project]/[name]/
        .git/                      # Git repository metadata
        Gopkg.lock                 # dep file
        Gopkg.toml                 # dep file
        pkg/
            api/
                ...
            ctl/
                ...
        cmd/
            hoge-api/
                main.go
            hogectl/
                main.go
        test/
        test-data/
```


## Bootstrap project directory
```
PROJECT=go-samples
mkdir -p ${GOPATH}/src/github.com/syunkitada/$PROJECT
cd ${GOPATH}/src/github.com/syunkitada/$PROJECT
mkdir -p cmd
mkdir -p pkg
mkdir -p test
dep init
cat << EOS > .gitignore
/vendor/
EOS

git init
git add .
git commit -m 'first commit'
```


## cmd
* cmdは、cmd/[cmd name]/main.go に置く

```
$ mkdir -p cmd/webapp-server
$ vim cmd/webapp-server/main.go
```


## godoによる自動実行の設定
* 特定のファイルを監視し、編集時に自動でgoの再ビルド・再実行や、特定のコマンドを実行することができる

> cmd/godoctl/main.go
```
package main

import (
    do "gopkg.in/godo.v2"
)

func tasks(p *do.Project) {
    p.Task("compile-pb", nil, func(c *do.Context) {
        c.Bash("protoc -I pkg/grpc/simple/pb pkg/grpc/simple/pb/pb.proto --go_out=plugins=grpc:pkg/grpc/simple/pb")
    }).Src("pkg/grpc/**/*.proto")

    p.Task("sample-grpc-simple", nil, func(c *do.Context) {
        c.Start("main.go", do.M{"$in": "cmd/sample-grpc-simple"})
    }).Src("pkg/grpc/**/*.go")
}

func main() {
    do.Godo(tasks)
}
```

* --watchオプションを付けて実行すると、特定ファイルを監視し、編集時に設定したタスクを自動実行する

```
$ go run cmd/sample-godo/main.go sample-grpc-simple --watch
```
