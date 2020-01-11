# DNS


## 基礎
* TODO


## IPv6
* TODO


## メモ: PTRレコードの主な用途
* 電子メールの受信拒否
* 広告の表示(ジオロケーション)
* SSH接続の許可
* ログファイル
* Traceroute
* サービスデスカバリ


## セキュリティ関連の用語
* DNS Cache Poisoning
    * DNS(キャッシュ)サーバの脆弱性を利用して、偽のレコードを登録して攻撃する手法
* DNS Rebinding
    * DNSの返すIPアドレスを巧妙に変化させることにより、JavaScriptなどのsame origin policyを破って攻撃する手法
    * 攻撃者は、自分のコントロール可能なドメイン名を持っている、もしくは、ドメイン名を管理しているDNSサーバを攻撃者が持っている必要がある
    * DNSキャッシュサーバが間にあるとうまくドメイン名に紐ずくIPを変えることができないので、TTLを0もしくは非常に短くする
* DNS Pinning
    * ブラウザは毎回ドメインを解決するのではなく、ドメインを解決したらその結果を再利用することで、途中でIPアドレスが変更されることを防ぐ
    * TTLの短いレコードを無視する場合もある


## 参考
* [DNS再入門](https://www.slideshare.net/ttkzw/dnstudy-01-dnsprimer)