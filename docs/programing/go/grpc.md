# gRPC


## References
* https://grpc.io/docs/guides/
    * 概要については公式を参照
* https://grpc.io/docs/quickstart/go.html
    * Unary RPCを試してみる
* https://grpc.io/docs/tutorials/basic/go.html
    * Goのチュートリアル
* https://github.com/grpc/grpc-go/blob/master/Documentation/gomock-example.md
    * Gomockを使ったテスト


## Install
```
# Install protocol buffer
# https://github.com/google/protobuf/releases
$ sudo unzip -d /usr/local protoc-3.5.1-linux-x86_64.zip
$ sudo chmod 755 /usr/local/bin/protoc

# Install go plugin
$ go get -u github.com/golang/protobuf/protoc-gen-go

# Install go grpc
$ go get google.golang.org/grpc
```
