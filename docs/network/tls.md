# TLS


## TLS(Transport Layer Security)とは？
* 暗号化、認証のためのプロトコル
* 元々はSSL(Secure Sockets Layer)という名前だったが、バージョンアップを重ねた後、SSL3.0を元にTLS（Transport Layer Security）1.0がRFCとして定められた
* その後、TLSが一般的に使われるようになったが、昔の名残でTLSのことをSSLやSSL/TLSと言ったりもする


## TLSサーバ証明書(サーバID)
* 大きく分けてドメイン名認証型と企業認証型の２つがある
    * ドメイン名認証型(DV)
        * ドメインの所有者と証明発行を申し込んできた運営者が同一であることを確認してから発行される
        * 身元確認はしないので、実在性は証明しない
    * 企業認証型(OV)
        * DVの確認に加えて、帝国データバンクや登記事項証明書の確認、電話による申請者の在籍・役職と申請の意思確認などが行われから発行される
    * 企業認証型(EV)
        * OVの確認に加えて、事業所の実在性の確認と事業所への申請責任者確認書の送付・返送が必要などが行われてから発行される
* TLS証明書は認証局に発行してもらうものだが、独自にサーバ証明書を発行することもできる
* TLS証明書の信頼性は、EV > OV > DV > 独自 となる
* TLS証明書には、以下のような情報が含まれる
    * 公開鍵
    * 有効期限
    * Subject: CommonName
        * サーバのホスト名を設定する(必須)
        * クライアントがアクセスした際にURLと、Subjectが一致しているかを検証します
    * Subject: Alt Name
        * Subjectの別名を複数設定できる(オプション)


## WEBサーバ側の準備
1. 秘密鍵・公開鍵のペアを作成する
2. 公開鍵を使ってTLSサーバ証明書を発行する
    * サーバ証明書は、基本的に複数の証明書から構成された階層構造になっている
    * SSL接続の際には、ブラウザは下位層から順に証明書を検証し、中間CA証明書、最上位のルートCA証明書までを検証する
3. WEBサーバに秘密鍵、SSLサーバ証明書を設定しHTTPSを有効にする


## TLSのフロー
1. クライアント: HTTPSでサーバにアクセス
2. サーバ: サーバ証明書をクライアントに返信
3. クライアント: 証明書の信頼性をチェック
4. クライアント: 共通鍵を作成し、証明書に含まれる公開鍵によって共通鍵を暗号化してサーバに送信
5. サーバ: 秘密鍵によって共通鍵を複合化する
6. 以降の通信は、共通鍵で通信される


## 独自TLS

### 独自のサーバ証明書を作る
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

### 独自のルートCA証明書を作成する
* ルートCA証明書を作り、サーバ証明書をルートCA証明書で認可できるようにする
``` bash
$ openssl genrsa -out ca-key.pem 4096
$ openssl req -x509 -new -nodes -key ca-key.pem -days 365 -out ca.pem -subj "/CN=localhost"
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
DNS.1 = localhost
EOS

$ openssl genrsa -out apiserver-key.pem 4096
$ openssl req -new -key apiserver-key.pem -out apiserver.csr -subj "/CN=localhost" -config openssl.cnf
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

### 参考
* [Cluster TLS using OpenSSL] (https://coreos.com/kubernetes/docs/latest/openssl.html)
