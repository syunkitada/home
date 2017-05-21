# 独自TLS

## 独自のサーバ証明書を作る
* 以下の手順でサーバ証明書を作ります
* Webサーバにサーバ証明書(server.crt)と秘密鍵(server.key)を設定すればHTTPSが利用できます
```
cat << EOS > openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.hoge.co.jp
DNS.2 = *.piyo.co.jp
EOS

openssl genrsa -out server.key 4096
openssl req -new -key server.key -out server.csr -subj "/CN=*.example.co.jp" -config openssl.cnf
openssl x509 -days 365 -req -signkey server.key -in server.csr -out server.crt
```

## ルートCA証明書を作り、サーバ証明書をルートCA証明書で認可する
### 独自のルートCA証明書を作成する
``` bash
$ openssl genrsa -out ca-key.pem 4096
$ openssl req -x509 -new -nodes -key ca-key.pem -days 365 -out ca.pem -subj "/CN=*.example.co.jp"
```


### サーバのkeypairを作成する
``` bash
$ cat << EOS > openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.hoge.co.jp
DNS.2 = *.piyo.co.jp
EOS

$ openssl genrsa -out apiserver-key.pem 4096
$ openssl req -new -key apiserver-key.pem -out apiserver.csr -subj "/CN=*.example.co.jp" -config openssl.cnf
$ openssl x509 -req -in apiserver.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out apiserver.pem -days 365 -extensions v3_req -extfile openssl.cnf
```


### 独自のルートCA証明書をクライアント側に追加する
* centos7
```
# /usr/share/pki/ca-trust-source/anchors に、CA証明書を配置する。
$ sudo cp mycacert.crt /usr/share/pki/ca-trust-source/anchors

# update-ca-trustコマンドを実行する。
$ sudo update-ca-trust extract
```

* ubuntu
```
# /usr/share/ca-certificates に、CA証明書を配置する。
$sudo cp mycacert.crt /usr/share/ca-certificates

# /etc/ca-certificates.confに、/usr/share/ce-certificetsからの相対パスで、ファイル名を追記する。
sudo vim /etc/ca-certificats.conf

# update-ca-certificetsを実行する。
sudo update-ca-certificates
```

## 参考
* [Cluster TLS using OpenSSL] (https://coreos.com/kubernetes/docs/latest/openssl.html)
