# DNS

## 基礎

- TODO

## IPv6

- TODO

## スタブリゾルバ

- リモートのリゾルバに毎回問い合わせするのではなく、ローカルにリゾルバを起動させてキャッシュさせる
- ローカルのリゾルバの事をスタブリゾルバとも呼ぶ
- スタブリゾルバがない場合
  - 名前解決のたびにリモートへ問い合わせるので効率が悪い
  - リモートの障害時に名前解決できなくなる
- スタブリゾルバ一覧
  - dnsmasq
    - デフォルトは、127.0.0.1:53 でリッスンする
    - /etc/resolv.conf などは手動で設定する必要がある
  - systemd-resolved
    - デフォルトは、127.0.0.53:53 でリッスンする
    - systemd パッケージに含まれている
    - /etc/resolv.conf は自動で設定される(シンボリックリンクが張られる)
      - /etc/resolv.conf -> ../run/systemd/resolve/stub-resolv.conf
    - resolver は、以下のファイルで設定する
      - /etc/systemd/resolved.conf
      - /etc/systemd/resolved.conf.d/
      - 編集したらリスタートする
        - sudo systemctl restart systemd-resolved

## メモ: PTR レコードの主な用途

- 電子メールの受信拒否
- 広告の表示(ジオロケーション)
- SSH 接続の許可
- ログファイル
- Traceroute
- サービスデスカバリ

## セキュリティ関連の用語

- DNS Cache Poisoning
  - DNS(キャッシュ)サーバの脆弱性を利用して、偽のレコードを登録して攻撃する手法
- DNS Rebinding
  - DNS の返す IP アドレスを巧妙に変化させることにより、JavaScript などの same origin policy を破って攻撃する手法
  - 攻撃者は、自分のコントロール可能なドメイン名を持っている、もしくは、ドメイン名を管理している DNS サーバを攻撃者が持っている必要がある
  - DNS キャッシュサーバが間にあるとうまくドメイン名に紐ずく IP を変えることができないので、TTL を 0 もしくは非常に短くする
- DNS Pinning
  - ブラウザは毎回ドメインを解決するのではなく、ドメインを解決したらその結果を再利用することで、途中で IP アドレスが変更されることを防ぐ
  - TTL の短いレコードを無視する場合もある

## 参考

- [DNS 再入門](https://www.slideshare.net/ttkzw/dnstudy-01-dnsprimer)
