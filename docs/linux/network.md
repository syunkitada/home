# Network

## NAPI 対応の受信処理(Kernel2.6 以降)

- Kernel2.6 ではデバイスドライバに対して NAPI(New API)と呼ばれる新しい受信 API が提供されるようになった。
- ネットワークインタフェースで受信したパケットは、デバイスドライバの H/W 割り込み処理処理で刈り取られる。
- ハードウェア割り込みが発生すると、H/W 割り込みを禁止してポーリング処理によってデバイスの受信バッファからパケットを取り出していく。
- バッファが空になって受信処理が完了すると、割り込みを再度許可状態にして、次の受信が発生するのを待つようにしている。

参考

- http://wiki.bit-hive.com/linuxkernelmemo/pg/%C1%F7%BC%F5%BF%AE
- http://syuu1228.hatenablog.com/entry/20101015/1287095708

## ソケットインタフェース

- TCP ソケットは listen()関数の第二引数 backlog に指定した数の、完全に確立された接続要求を待ち受けることができるキューを作成します。
- キューがいっぱいになった状態で新たに接続を受け取ると、サーバは ECONNREFUSED を返します。
- 下位層のプロトコルが再送をサポートしていれば、ECONNREFUSED は無視され、リトライが成功するかもしれません。
- net.core.somaxconn は、TCP ソケットが受け付けた接続要求を格納する、キューの最大長です。
- backlog > net.core.somaxconn のとき、キューの大きさは暗黙に net.core.somaxconn に切り詰められます。

```
# backlogの最大値
net.core.netdev_max_backlog = 1000

# synbacklogの最大値
net.ipv4.tcp_max_syn_backlog = 128

# 実際のbacklogの設定はアプリケーションにゆだねられる
# syn backlogはbacklog値を8~max_syn_backlogの範囲に収めた後、一つ上の2のべき乗の値に切り上げた値となる
# 例えばbacklogが200ならsyn backlogは256となり、backlogが256ならsyn backlogサイズは512になる

# TCPセッションのキュー
# TCPセッション数をbacklogで管理し、それを超えたものがこのキューで管理される
# tcp_max_syn_backlogを大きくしても、somaxconnが小さいと、backlogも小さく切り詰められ、syn backlogもつ遺作なる
$ sysctl net.core.somaxconn
128

# パケットの取りこぼしは、netstatで確認できる
$ netstat -s
...
TcpExt:
    107708 times the listen queue of a socket overflowed
    107708 SYNs to LISTEN sockets dropped
```

参考

- http://wiki.bit-hive.com/linuxkernelmemo/pg/listen%20backlog%20%A1%DA3.6%A1%DB

プロトコルスタック
ネットワークデバイス
netfilter
コネクション
るーてキング
パケットスケジューラー
3 ウェイハンドシェイク
ルーティングテーブル
FIB
RIB
トライ木
bufferbloat
busypool

## TCP

```
# TIME_WAIT状態がタイムアウトする時間
net.ipv4.tcp_fin_timeout = 30
```

## DDOS 対策

```
# syn flood攻撃対策
# syn flood状態になると、synパケットにメモリ領域を割り当てずに、シーケンス番号を正しくチェックするため特殊な情報をSYN ACKパケットに含ませて返すようになる
# そして、クライアントが正しくACKを返せば、TCP接続を行う
net.ipv4.tcp_syncookies = 1

# syn flood状態になると、新規のSYN_RECVは登録せずに破棄する
net.ipv4.tcp_syncookies = 0

# Smurf攻撃対策
net.ipv4.icmp_echo_ignore_broadcasts = 1

# ICMPエラー無視
net.ipv4.icmp_ignore_bogus_error_responses = 1
```

| Aplications |

| System Call Interface |

| SocketInterface |

| ProtocolStuck | Netfilter |

| NetDevice (Driver を抽象化した Device) |

| Device Drivers |

| NetworkDevice(NIC)

## Bufferbloat

- 不適切なネットワークキューイングや過剰なバッファによりレイテンシーが悪化、または不安定な状態
- レイテンシーの悪化、揺らぎにより、TCP の服装制御の混乱を招き、スループットの低下も起こる

## メモ

```
Linux の Network Scheduler デフォルトは FIFO
ab -> IP Stack -> queue queue queue -> NIC Buffer
db -> | -- Buffer Size -- |

Nic のバッファサイズが大きいとロスが増加

遅いもの、大きいものは処理に時間がかかる
早いもの、小さいものはその逆 VoIP とか DNS とか

アクティブキューイング
FIFO を廃止し、キューイングを様々な方法で制御

CoDel(Controlled Delay)
RTT やプロトコル等を考慮して必要に応じてキューの先頭に割り込む

TCP small queues
Byte Queue Limits
```

## sysctl

- net.\*.conf.lo.rp_filter
  - Reverse Path Filter
  - 複数 NIC のサーバに置いて、ある IF から受信したパケットが、別の IF から送信される場合がある
  - パケットが入ってくる経路と、出てく経路が異なる場合に、そのパケットをフィルタリングする設定
  - 設定値
    - 0: 無効
    - 1: Strict Mode: ある IF で受信したパケットの返信先がその IF のネットワークアドレスと同じ場合は、許可
    - 2: Loose Mode: ある IF で受信したパケットの送信元 IP がいずれかの IF より到達可能の場合は、許可
- net.\*.conf.lo.arp_filter
  - ARP Filter
  - 設定値
    - 0: 別のインターフェースからのアドレスの ARP 要求に対応できます
    - 1: 同じサブネットで複数のネットワークインターフェースを持つことを可能にし、カーネルがインターフェースから ARP 要求 の IP パケットをルーティングするかどうかに基づいて、各インターフェースの ARP が応答できるようにします

## Refarence

- [Linux カーネルメモ 送受信](http://wiki.bit-hive.com/linuxkernelmemo/pg/%C1%F7%BC%F5%BF%AE)
- [ネットワーク関係記事まとめ 2013/06](http://syuu1228.hatenablog.com/entry/20130603/1370300554)
