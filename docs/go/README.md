# Go

## Install
```
$ wget https://storage.googleapis.com/golang/go1.7.5.linux-amd64.tar.gz
$ sudo tar -C /usr/local -xzf go1.7.5.linux-amd64.tar.gz
$ export PATH=$PATH:/usr/local/go/bin
```

## Hello world
```
$ mkdir $HOME/work
$ cd work

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
