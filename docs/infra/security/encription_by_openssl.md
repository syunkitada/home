# Encription by openssl

- openssl enc [command] で暗号・複合を行うことができる
- enc: Encoding with Ciphers の略

```
$ openssl version
OpenSSL 1.1.1  11 Sep 2018
```

## 利用できる暗号化一覧

```
$ openssl enc -ciphers
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

## 暗号化・複合化

```
# $ openssl enc [cipher option] -in [input] -out [output] [options]

# passwordは、-pass で指定するか、
# 指定しない場合は、以下のように標準入力から入力する
# -pbkdf2: Use password-based key derivation function 2
$ openssl enc -e -aes-256-cbc -pbkdf2 -in hoge -out hoge.enc
enter aes-256-cbc encryption password:
Verifying - enter aes-256-cbc encryption password:

# コマンドライン引数でパスワードを設定する場合は以下
$ openssl enc -e -aes-256-cbc -pbkdf2 -in hoge -out hoge.enc -pass pass:hoge
openssl enc -aes-256-cbc -pbkdf2 -in hoge -out hoge.enc -pass pass:hoge


# openssl enc -d [cipher option] -in [input] -out [output]
$ openssl enc -d -aes-256-cbc -pbkdf2 -in hoge.enc -out hoge.enc.out
enter aes-256-cbc decryption password:
```

## RSA を使っての暗号化・複合化

```
# 秘密鍵(private-key.pem)を作成
## パスフレーズなし
$ openssl genrsa -out private-key.pem
## パスフレーズあり(aes256で暗号化)
$ openssl genrsa -out private-key.pem -aes256

# 秘密鍵(private-key.pem)から公開鍵(public-key.pem)を作成(パスフレーズが必要)
$ openssl rsa -in private-key.pem -pubout -out public-key.pem
Enter pass phrase for private-key.pem:


# 公開鍵で暗号化
$ openssl rsautl -encrypt -in hoge -out hoge.enc -inkey public-key.pem -pubin

# 秘密鍵で複合化(パスフレーズが必要)
$ openssl rsautl -decrypt -in hoge.enc -out hoge.enc.out -inkey private-key.pem
Enter pass phrase for private-key.pem:


# 秘密鍵で暗号化(パスフレーズが必要)
$ openssl rsautl -encrypt -in hoge -out hoge.enc -inkey private-key.pem
Enter pass phrase for private-key.pem:

# 公開鍵で複合化
$ openssl rsautl -encrypt -in hoge -out hoge.enc -inkey public-key.pem -pubin
```

## x509 証明書を使っての暗号化・複合化

```
# x509の公開鍵、秘密鍵を作成
$ openssl req -x509 -nodes -newkey rsa:2048 -keyout private-key.pem -out public-key.pem -subj /CN=client.example.com

# 公開鍵で暗号化
$ openssl smime -encrypt -binary -aes-256-cbc -in hoge -out hoge.enc -outform DER public-key.pem

# 秘密鍵で複合化
$ openssl smime -decrypt -binary -in hoge.enc -inform DER -out hoge.enc.out -inkey private-key.pem
```
