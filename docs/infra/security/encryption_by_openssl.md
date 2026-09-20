# Encryption with OpenSSL

- openssl enc [command] で暗号・復号を行うことができる
- enc: Encoding with Ciphers の略

```
$ openssl version
OpenSSL 3.x
```

## 利用できる暗号化一覧

```
$ openssl enc -list
Supported ciphers:
-aes-128-cbc               -aes-128-cfb               -aes-128-cfb1
-aes-128-cfb8              -aes-128-ctr               -aes-128-ecb
-aes-128-ofb               -aes-192-cbc               -aes-192-cfb
-aes-192-cfb1              -aes-192-cfb8              -aes-192-ctr
-aes-192-ecb               -aes-192-ofb               -aes-256-cbc
-aes-256-cfb               -aes-256-cfb1              -aes-256-cfb8
-aes-256-ctr               -aes-256-ecb               -aes-256-ofb
-aes128                    -aes128-wrap               -aes192
-aes192-wrap               -aes256                    -aes256-wrap
-aria-128-cbc              -aria-128-cfb              -aria-128-cfb1
...
```

## 暗号化・復号

`openssl enc` のCBC例は暗号化だけを行い、改ざん検知用の認証タグを提供しません。新規の運用では、認証付きの方式を備えた `age` や `gpg` などの専用ツールも検討してください。

```
# $ openssl enc [cipher option] -in [input] -out [output] [options]

# passwordは、-pass で指定するか、
# 指定しない場合は、以下のように標準入力から入力する
# -pbkdf2: Use password-based key derivation function 2
$ openssl enc -e -aes-256-cbc -pbkdf2 -in hoge -out hoge.enc
enter aes-256-cbc encryption password:
Verifying - enter aes-256-cbc encryption password:

# 非対話式にする場合は、パスワードをコマンドラインに直接書かない
# 例: 権限を制限したファイルから読み込む
$ openssl enc -e -aes-256-cbc -pbkdf2 -in hoge -out hoge.enc -pass file:/path/to/password.txt


# openssl enc -d [cipher option] -in [input] -out [output]
$ openssl enc -d -aes-256-cbc -pbkdf2 -in hoge.enc -out hoge.enc.out
enter aes-256-cbc decryption password:
```

## RSA を使った短いデータの暗号化・復号

RSA は大量のデータを直接暗号化する用途には使わず、通常は共通鍵を暗号化するために使います。
`rsautl` は OpenSSL 3.0 で非推奨になったため、`pkeyutl` を使用します。

```
# 秘密鍵(private-key.pem)を作成
## パスフレーズなし
$ openssl genrsa -out private-key.pem
## パスフレーズあり(aes256で暗号化)
$ openssl genrsa -out private-key.pem -aes256

# 秘密鍵(private-key.pem)から公開鍵(public-key.pem)を作成(パスフレーズが必要)
$ openssl pkey -in private-key.pem -pubout -out public-key.pem
Enter pass phrase for private-key.pem:


# 公開鍵で暗号化
$ openssl pkeyutl -encrypt -in hoge -out hoge.enc -pubin -inkey public-key.pem \
    -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256 \
    -pkeyopt rsa_mgf1_md:sha256

# 秘密鍵で復号(パスフレーズが必要)
$ openssl pkeyutl -decrypt -in hoge.enc -out hoge.enc.out -inkey private-key.pem \
    -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256 \
    -pkeyopt rsa_mgf1_md:sha256
Enter pass phrase for private-key.pem:
```

## X.509 証明書を使った暗号化・復号

```
# x509の公開鍵、秘密鍵を作成
$ openssl req -x509 -newkey rsa:2048 -keyout private-key.pem -out certificate.pem -subj /CN=client.example.com

# 公開鍵で暗号化
$ openssl smime -encrypt -binary -aes-256-cbc -in hoge -out hoge.enc -outform DER certificate.pem

# 秘密鍵で復号
$ openssl smime -decrypt -binary -in hoge.enc -inform DER -out hoge.enc.out -inkey private-key.pem
```
