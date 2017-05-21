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