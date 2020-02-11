# iptables

## netfilter とは

- カーネルのパケット処理を hook してユーザランドで制御できるようにしたもの
- ユーザ側で操作、参照しやすい形態
- iptables もそのコンポーネントの一つ
- conntrack, ulogd, ip6tables, arptables, ebtables 等も含まれる

## conntrack

- connection tracking の略ですべての通信がリアルタイムに記録される
- TCP の通信が終了した場合でも、設定されたタイムアウトまで蓄積される
- タイムアウトすると conntrack table から破棄される
- src dst IP と Port の tuple を hash 化して hash table で処理している
- conntrack table の確認
  - conntrack table は多い時で 10 万近いリストになることもある
  - cat /proc/net/nf_conntrack でも見れるが古いやり方(最新のカーネルだと、procfs 自体から消えてる
  - conntrack-tools を使う
  - $ yum install conntrack-tools, $ apt-get install conntrack
  - \$ conntrack -L
  - [ASSURED]は破棄されず、[UNREPLIED]は timeout か上限数に達すると破棄される
- 観測パターン
  - [ASSURED] + SYN_SENT が増える(SYN_ACK が返ってこない)
    - コネクション要求に失敗してる
  - HALF-ASSURED が増える([ASSURED][unreplied]に遷移しない])
    - コネクション要求に失敗してる
  - SYN_SENT まで通る場合
    - その先のロードバランサやリアルサーバの問題の可能性が多い
  - HALF-ASSURED が増加する場合
    - コネクションオープンまたは、クローズの要求に応答が戻ってこない状態
    - NW 的に疎通不可能か、レスポンスが極端に低下している
  - [ASSURED] + ESTABLISHED が増える（終了しない通信が増える)
    - コネクションは確立しているがレスポンスがない
  - CLOSE が増加する場合
    - コネクションは確立したけど、レスポンスがないため開きっぱなしのコネクションが増加
    - リアルサーバからレスポンスがなく通信が FIN へ遷移しないコネクションが増加している状態
    - 逆 SYN flood 状態

## iptables

```
$ iptables [-t テーブル] コマンド [マッチ][ターゲット/ジャンプ]
```

- テーブルとチェイン
  - それぞれのテーブルの中で、どのタイミングでフィルタリングするかを決めるのがチェイン
- テーブル
  - filter テーブル
    - INPUT、OUTPUT、FORWARD
  - nat テーブル
    - POSTROUTING、PREROUTING、OUTPUT
  - mangle テーブル
    - POSTROUTING、PREROUTING、INPUT、OUTPUT、FORWARD
  - raw テーブル
    - PREROUTING、OUTPUT
- チェイン
  - INPUT
    - 入力（受信）に対するチェイン
  - OUTPUT
    - 出力（送信）に対するチェイン
  - FORWARD
    - フォアード（転送）に対するチェイン
  - PREROUTING
    - 受信時に宛先アドレスを変換するチェイン
    - タイミングとしては filter で適用されるルールより手前
  - POSTROUTING
    - 送信時に送信元アドレスを変換するチェイン
    - これも filter の後でパケットが送信される直前
- パケットフロー
  - http://inai.de/images/nf-packet-flow.png

## コマンド

- -A（--append） 指定チェインに 1 つ以上の新しいルールを追加
- -D（--delete） 指定チェインから 1 つ以上のルールを削除
- -P（--policy） 指定チェインのポリシーを指定したターゲットに設定
- -N（--new-chain） 新しいユーザー定義チェインを作成
- -X（--delete-chain） 指定ユーザー定義チェインを削除
- -I（--insert） 指定したチェーンにルール番号を指定してルールを挿入する。（ルール番号を省略した際にはルール番号は 1 に設定され、チェーンの先頭に挿入される。）

## パラメータ

- -s (--source) パケットの送信元を指定。特定の IP（192.168.0.1）や範囲（192.168.0.0/24）を指定する
- -d (--destination) パケットの宛先を指定。指定方法は-s と同じ。
- -p (--protocol) チェックされるパケットのプロトコル。 指定できるプロトコルは、 tcp、udp、icmp、all のいずれか 1 つか、数値。
- -i (--in-interface) パケットを受信することになるインターフェース名。eth0、eth1 など
- -o (--out-interface) 送信先インターフェース名を指定
- -j (--jump) [ターゲット]
  - ターゲットの一覧
    - ACCEPT: パケットの通過を許可
    - DROP: パケットを破棄。応答を返さない。
    - REJECT: パケットを拒否し、ICMP メッセージを返信
    - REDIRECT: 特定ポートにリダイレクト
    - LOG: マッチしたパケットのログを記録
    - MASQUERADE: NAT 時のポートの変換

## NAT（Network Address Translation)

- NAT とは IP アドレスを変換して転送する仕組み
  - IP Masquerde は、NAT に加えて UDP/TCP のポート番号の 変換まで行う
  - NAT されてフォワードした通信は、conntrack に記録され、戻りの通信は再度変換されて送信元に戻る
- DNAT: Destination IP を NAT する
- SNAT: Source IP を NAT する

```
# ホスト上のローカルネットワークからNATして外部と通信する例
sudo iptables -t nat -A POSTROUTING -p TCP -s 172.16.100.0/24 ! -d 172.16.100.0/24 -j MASQUERADE --to-ports 30000-40000
sudo iptables -t nat -A POSTROUTING -p UDP -s 172.16.100.0/24 ! -d 172.16.100.0/24 -j MASQUERADE --to-ports 30000-40000
sudo iptables -t nat -A POSTROUTING -s 172.16.100.0/24 ! -d 172.16.100.0/24 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 172.16.100.0/24 -d 255.255.255.255 -j RETURN
sudo iptables -t nat -A POSTROUTING -s 172.16.100.0/24 -d base-address.mcast.net/24 -j RETURN
```

## Note

```
# どのルールにマッチしたかを確認する
$ sudo iptables -t nat -vL

Chain POSTROUTING (policy ACCEPT 6602 packets, 403K bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MASQUERADE  all  --  any    !docker0  172.17.0.0/16        anywhere
    9   540 MASQUERADE  tcp  --  any    any     192.168.100.0/24    !192.168.100.0/24     masq ports: 30000-40000
   29  2112 MASQUERADE  udp  --  any    any     192.168.100.0/24    !192.168.100.0/24     masq ports: 30000-40000
    0     0 MASQUERADE  all  --  any    any     192.168.100.0/24    !192.168.100.0/24
```

## References

- [俺史上最強の iptables をさらす](http://qiita.com/suin/items/5c4e21fa284497782f71)
