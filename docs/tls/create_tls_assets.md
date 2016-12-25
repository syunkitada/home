# 独自TLS

## 独自のルートCA証明書を作成する
``` bash
$ openssl genrsa -out ca-key.pem 2048
$ openssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem -subj "/CN=kube-ca"
```


## APIサーバのkeypairを作成する
* alt_namesなどは適宜変更する
openssl.cnf
```
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = hoge
DNS.2 = hoge.piyo
DNS.3 = hoge.piyo.co.jp
IP.1 = 192.168.122.50
IP.2 = 10.3.0.1
```

``` bash
$ openssl genrsa -out apiserver-key.pem 2048
$ openssl req -new -key apiserver-key.pem -out apiserver.csr -subj "/CN=hoge-apiserver" -config openssl.cnf
$ openssl x509 -req -in apiserver.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out apiserver.pem -days 365 -extensions v3_req -extfile openssl.cnf
```


## 独自のルートCA証明書をクライアント側に追加する
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
