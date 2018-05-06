# Project Bootstrap


## Project Tree
```
bin/
    ...
pkg/
    ...
src/
    github.com/[project]/[name]/
        .git/                      # Git repository metadata
        Gopkg.lock                 # dep file
        Gopkg.toml                 # dep file
        cmd/
            hoge/
                main.go
```


## Initial project directory
```
mkdir -p ${GOPATH}/src/github.com/syunkitada/go-gin-sample
cd ${GOPATH}/src/github.com/syunkitada/go-gin-sample
dep init
cat << EOS > .gitignore
/vendor/
EOS

git init
git add .
git commit -m 'first commit'
git remote add origin https://github.com/syunkitada/go-gin-sample.git
git push origin master
```


## cmd
* cmdは、cmd/[cmd name]/main.go に置く

```
$ mkdir -p cmd/webapp-server
$ vim cmd/webapp-server/main.go
```
