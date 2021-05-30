# Network

## NAPI 対応の受信処理(Kernel2.6 以降)

- Kernel2.6 ではデバイスドライバに対して NAPI(New API)と呼ばれる新しい受信 API が提供されるようになった。
- ネットワークインタフェースで受信したパケットは、デバイスドライバの H/W 割り込み処理処理で刈り取られる。
- ハードウェア割り込みが発生すると、H/W 割り込みを禁止してポーリング処理によってデバイスの受信バッファからパケットを取り出していく。
- バッファが空になって受信処理が完了すると、割り込みを再度許可状態にして、次の受信が発生するのを待つようにしている。
- 参考
  - http://wiki.bit-hive.com/linuxkernelmemo/pg/%C1%F7%BC%F5%BF%AE
  - http://syuu1228.hatenablog.com/entry/20101015/1287095708

## ソケットインタフェース

- TCP ソケットは listen()関数の第二引数 backlog に指定した数の、完全に確立された接続要求を待ち受けることができるキューを作成します。
- キューがいっぱいになった状態で新たに接続を受け取ると、サーバは ECONNREFUSED を返します。
- 下位層のプロトコルが再送をサポートしていれば、ECONNREFUSED は無視され、リトライが成功するかもしれません。
- net.core.somaxconn は、TCP ソケットが受け付けた接続要求を格納する、キューの最大長です。
- backlog > net.core.somaxconn のとき、キューの大きさは暗黙に net.core.somaxconn に切り詰められます。
- 参考
  - [listen backlog](http://wiki.bit-hive.com/linuxkernelmemo/pg/listen%20backlog%20%A1%DA3.6%A1%DB)

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

## TCP

```
# sysctlの各種パラメータの詳細はmanで調べるとよい
$ man tcp 7

# TIME_WAIT状態がタイムアウトする時間
net.ipv4.tcp_fin_timeout = 30

# [low, pressure, high] からなるベクトル値(単位はページ: 通常は4k）
# アロケートしたページがlow以下であれば、メモリアロケーションは調整しない
# pressureを超えると、TCPはメモリ消費を調整するようになる
# highはアロケートできる最大値
net.ipv4.tcp_mem = 383457       511277  766914

# 単位はバイト
net.ipv4.tcp_rmem = 4096        131072  6291456
net.ipv4.tcp_wmem = 4096        16384   4194304
```

## stat

#### /proc/net/protocols

- 各プロトコルが memory pressure モードであるかを確認する
- press が yes となってれば pressure モードとなっているので注意
- memory が実際にアロケートしているページ数
- memory が、tcp_mem の pressure を超えると pressure モードとなり、以下の処理をする
  - TCP ソケットの送信・受信バッファのサイズを制限する
  - 受信の TCP ウィンドウサイズを小さくする（もしくは ZeroWindow にする)
  - 受信キューに入ったセグメントから重複したシーケンス番号をもつセグメントをマージして、空きメモリの確保を試みる(collapse 処理）
  - シーケンス番号順に受信できなかったセグメントを保持する Ouf of Order キューに入った SACK 済みセグメントを破棄して空きメモリを確保する（prune 処理）
  - 受信スロースタートの閾値を制限する
- memory が、tcp_mem の high を超える以下の処理を行う
  - セグメントの受信処理で、新規に受信したセグメントを破棄する（Drop）
  - セグメントの送信処理で、メモリを確保できるまでプロセスをブロックして待機させる
  - セグメント受信処理で、Ouf of Order キューのセグメントを破棄して空きを確保しようとする(SACK renege)
  - 一部の TCP のタイマー処理をやり直す
  - 送信バッファに一定量のデータをもったままのソケットを close すると TCP oom を起こす
    - TCP oom では、RST を送信してコネクションをクローズさせ、dmesg に TCP oom のログを出す

```
$ cat /proc/net/protocols
protocol  size sockets  memory press maxhdr  slab module     cl co di ac io in de sh ss gs se re sp bi br ha uh gp em
PACKET    1408      2      -1   NI       0   no   kernel      n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n
PINGv6    1136      0      -1   NI       0   yes  kernel      y  y  y  n  n  y  n  n  y  y  y  y  n  y  y  y  y  y  n
RAWv6     1136      2      -1   NI       0   yes  kernel      y  y  y  n  y  y  y  n  y  y  y  y  n  y  y  y  y  n  n
UDPLITEv6 1280      0       1   NI       0   yes  kernel      y  y  y  n  y  y  y  n  y  y  y  y  n  n  n  y  y  y  n
UDPv6     1280      2       1   NI       0   yes  kernel      y  y  y  n  y  y  y  n  y  y  y  y  n  n  n  y  y  y  n
TCPv6     2304      2      36   yes    304   yes  kernel      y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
XDP        960      0      -1   NI       0   no   kernel      n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n
UNIX      1024    111      -1   NI       0   yes  kernel      n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n
UDP-Lite  1088      0       1   NI       0   yes  kernel      y  y  y  n  y  y  y  n  y  y  y  y  y  n  n  y  y  y  n
PING       928      0      -1   NI       0   yes  kernel      y  y  y  n  n  y  n  n  y  y  y  y  n  y  y  y  y  y  n
RAW        936      0      -1   NI       0   yes  kernel      y  y  y  n  y  y  y  n  y  y  y  y  n  y  y  y  y  n  n
UDP       1088      4       1   NI       0   yes  kernel      y  y  y  n  y  y  y  n  y  y  y  y  y  n  n  y  y  y  n
TCP       2144     28      36   yes👈  304   yes  kernel      y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
NETLINK   1064     15      -1   NI       0   no   kernel      n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n

```

#### /proc/net/netstat

- netstat: TCPMemoryPressures
  - memory pressure モードに入ると 1 インクリメントされる
- netstat: TCPMemoryPressuresChrono
  - memory pressure モードであった時間が加算される
- netstat: OfoPruned
  - Ofo は Ouf of Order の略で、TCP の Ouf of Order キューを指す
  - memory pressure モードで Ofo キューのパケットを破棄すると 1 インクリメントされる
- netstat: TCPAbortOnMemory
  - TCP oom が発生すると 1 インクリメントされる
- netstat: PruneCalled, RcvPrune
  - net.ipv4.tcp_mem の high を超えていて、受信キューの collapse 処理と Ofo キューのパケットを破棄(Drop)を行ってもなお、空きメモリが確保できないと、1 インクリメントされる
- netstat: TCPRcvQDrop
  - net.ipv4.tcp_mem の high を超えていて、受信したパケットをドロップした際に 1 インクリメントされる
- netstat: TCPAbortFailed
  - TCP oom が発生すると該当のソケットで RST を送りコネクションを切断する
  - この際に、ソケットバッファの割り当てに失敗すると、1 インクリメントされる
    - ソケットバッファの割り当て失敗は、TCP クォータの制限による失敗ではなく、Slab アロケータによる割り当て失敗が原因となる

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

## 複数 NIC 利用時の注意点

- 複数の NIC が別々のセグメントに所属する場合
  - routeing table に NIC ごとの定義してあれば、routing table どおりに通信が可能
  - ルート定義がないセグメントから、デフォルトゲートウェイ以外の NIC に通信があった場合
    - 返信時の送信はデフォルトゲートウェイが利用される
    - このとき、デフォルトゲートウェイからの到達性がない場合はパケットは到達しない
- 複数の NIC が同一のセグメントに所属する場合
  - ARP Filter が 0 の場合、デフォルトゲートウェイ側の NIC が ARP 要求に応答してしまう
    - このため、デフォルトゲートウェイ以外の NIC への ARP は、ただしく解決できない
  - ARP Filter が 1 の場合、ARP を受信した NIC から応答するようになる

## netlink

- Linux カーネルのサブシステムの名称で、このサブシステムと、ユーザ空間のアプリケーションがやり取りするためのソケットベースの IPC が定義されている
- アプリケーションはソケット通信によって、Linux カーネル管理下のネットワーク関連リソースを操作したり、その状態を取得することができる
- ip コマンドや、ss コマンドもこの netlink を利用して、リソース情報を取得したり、操作を行っている
- 参考
  - [Netlink IPC を使って Linux カーネルのネットワーク情報にアクセスする](http://ilyaletre.hatenablog.com/entry/2019/09/01/205432)
  - [Kernel Korner - Why and How to Use Netlink Socket](https://www.linuxjournal.com/article/7356)
  - [Go による実装 2: docker.libcontainer](https://github.com/docker-archive/libcontainer/blob/master/netlink/netlink_linux.go)
    - container 用の必要最低限の実装なのでわかりやすい
  - [Go による実装 1: netlink](https://github.com/vishvananda/netlink)
    - もともとは libcontainer の netlink 機能をフォークしたものだがほぼ別物
    - netlink に絞ったもりもりの実装

## Refarence

- [Linux カーネルメモ 送受信](http://wiki.bit-hive.com/linuxkernelmemo/pg/%C1%F7%BC%F5%BF%AE)
- [ネットワーク関係記事まとめ 2013/06](http://syuu1228.hatenablog.com/entry/20130603/1370300554)
- [ペパボ トラブルシュート伝 - TCP: out of memory -- consider tuning tcp_mem の dmesg から辿る 詳解 Linux net.ipv4.tcp_mem](https://tech.pepabo.com/2020/06/26/kernel-dive-tcp_mem/)

## メモ

- プロトコルスタック
- ネットワークデバイス
- netfilter
- コネクション
- パケットスケジューラー
- ルーティングテーブル
- FIB
- RIB
- トライ木
- busypool

## 仮想ネットワークデバイス

- ipvlan
  - 親のネットワークデバイスから派生する子デバイス
  - 親デバイスは L2 と L3 を持ち、子デバイスは L3 のみを持つ
  - L2 の処理を親デバイスに任せる(L2 モード)
  - 一つのネットワークデバイスに複数の L3 アドレスを割り振るではダメなのか？
  - デバイスそのものをわけて使いたい場合がある
- bridge
- bonded interface
- team device
- vlan
- vxlan
- macvlan

## Refarences

- [Introduction to Linux interfaces for virtual networking](https://developers.redhat.com/blog/2018/10/22/introduction-to-linux-interfaces-for-virtual-networking/)
