# TLS

## TLS(Transport Layer Security)とは？

- 暗号化、認証のためのプロトコル
- 元々は SSL(Secure Sockets Layer)という名前だったが、バージョンアップを重ねた後、SSL3.0 を元に TLS（Transport Layer Security）1.0 が RFC として定められた
- その後、TLS が一般的に使われるようになったが、昔の名残で TLS のことを SSL や SSL/TLS と言ったりもする

## TLS サーバ証明書(サーバ ID)

- 大きく分けてドメイン名認証型と企業認証型の２つがある
  - ドメイン名認証型(DV)
    - ドメインの所有者と証明発行を申し込んできた運営者が同一であることを確認してから発行される
    - 身元確認はしないので、実在性は証明しない
  - 企業認証型(OV)
    - DV の確認に加えて、帝国データバンクや登記事項証明書の確認、電話による申請者の在籍・役職と申請の意思確認などが行われから発行される
  - 企業認証型(EV)
    - OV の確認に加えて、事業所の実在性の確認と事業所への申請責任者確認書の送付・返送が必要などが行われてから発行される
- TLS 証明書は認証局に発行してもらうものだが、独自にサーバ証明書を発行することもできる
- TLS 証明書の信頼性は、EV > OV > DV > 独自 となる
- TLS 証明書には、以下のような情報が含まれる
  - 公開鍵
  - 有効期限
  - Subject: CommonName
    - サーバのホスト名を設定する(必須)
    - クライアントがアクセスした際に URL と、Subject が一致しているかを検証します
  - Subject: Alt Name
    - Subject の別名を複数設定できる(オプション)

## WEB サーバ側の準備

1. 秘密鍵・公開鍵のペアを作成する
2. 公開鍵を使って TLS サーバ証明書を発行する
   - サーバ証明書は、基本的に複数の証明書から構成された階層構造になっている
   - SSL 接続の際には、ブラウザは下位層から順に証明書を検証し、中間 CA 証明書、最上位のルート CA 証明書までを検証する
3. WEB サーバに秘密鍵、SSL サーバ証明書を設定し HTTPS を有効にする

## TLS のフロー

1. クライアント: HTTPS でサーバにアクセス
2. サーバ: サーバ証明書をクライアントに返信
3. クライアント: 証明書の信頼性をチェック
4. クライアント: 共通鍵を作成し、証明書に含まれる公開鍵によって共通鍵を暗号化してサーバに送信
5. サーバ: 秘密鍵によって共通鍵を複合化する
6. 以降の通信は、共通鍵で通信される

## 自己証明書の作成

- [cfssl](https://github.com/cloudflare/cfssl)
  - 使用例: [Provisioning a CA and Generating TLS Certificates](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md)

## CAA レコード

- SSL/TLS 証明書の発行を許可する認証局を、ドメインの所有者が宣言するためのレコード
- 認証局は、証明書発行の際に、subjectAltName に記載されたドメインすべての CAA レコードをチェックすることが義務付けられており、証明書の不正発行や誤発行を防ぐ役割がある

```
;; ANSWER SECTION:
google.com.             86400   IN      CAA     0 issue "pki.goog"

;; ANSWER SECTION:
yahoo.co.jp.            900     IN      CAA     0 issue "globalsign.com"
yahoo.co.jp.            900     IN      CAA     0 issue "digicert.com;cansignhttpexchanges=yes"
yahoo.co.jp.            900     IN      CAA     0 iodef "mailto:nic-admin@mail.yahoo.co.jp"
yahoo.co.jp.            900     IN      CAA     0 issue "cybertrust.ne.jp"
```
