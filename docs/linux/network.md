# Network

> sysctl や `/proc` の値、既定のキューイング方式、NIC のオフロード対応は、カーネル・ディストリビューション・搭載メモリ・ドライバによって異なります。以下の数値は一般的な確認例であり、設定値をそのまま推奨するものではありません。

## NAPI 対応の受信処理

- NAPI は Linux 2.4 で導入された、割り込みとポーリングを組み合わせるネットワーク受信 API です。名称は現在では固有名詞として扱われ、`New API` の略とは限りません。
- 受信割り込みを契機に、ドライバは割り込みを抑制して NAPI の poll 処理をスケジュールします。通常の poll は softirq のコンテキストで実行されます。
- poll は予算（budget）の範囲で受信キューからパケットを処理します。キューが空になるなどして処理が完了すると NAPI を終了し、次の受信割り込みを有効にします。予算を使い切った場合は、次の poll に処理を持ち越します。
- 参考
  - [NAPI — The Linux Kernel documentation](https://docs.kernel.org/networking/napi.html)
  - [Linux カーネルメモ: 送受信](http://wiki.bit-hive.com/linuxkernelmemo/pg/%C1%F7%BC%F5%BF%AE)
  - [VA Linux エンジニアブログ: 詳解 Linux ネットワーク - NAPI 編 (前編)](https://valinux.hatenablog.com/entry/20220128)

## ソケットインタフェース

- TCP ソケットの `listen()` の第二引数 `backlog` は、通常、3-way handshake 完了後に `accept()` を待つ接続（accept queue）の長さを指定します。
- 接続確立前の SYN_RECV を保持するキューは別物で、上限の目安は `net.ipv4.tcp_max_syn_backlog` です。SYN cookies が有効な場合は、SYN backlog のあふれ方も変わります。
- accept queue が満杯でも、常に直ちに `ECONNREFUSED` になるとは限りません。`net.ipv4.tcp_abort_on_overflow` の設定やクライアントの再送によって挙動が変わります。
- `net.core.somaxconn` は listen backlog のカーネル側の上限です。`backlog` がこれを超える場合、実際の accept queue の長さは切り詰められます。
- `net.core.netdev_max_backlog` は NIC から上位のプロトコル処理へ渡す前の入力キューの上限であり、listen backlog とは別のキューです。
- 参考
  - [`listen(2)` — Linux manual page](https://man7.org/linux/man-pages/man2/listen.2.html)
  - [IP Sysctl — The Linux Kernel documentation](https://docs.kernel.org/networking/ip-sysctl.html)

```
# 入力キューの最大値（listen backlog とは別物）
net.core.netdev_max_backlog = 1000

# SYN_RECV キューの最大値
net.ipv4.tcp_max_syn_backlog = 128

# accept queue の上限。実際の listen backlog はアプリケーションの引数と
# net.core.somaxconn の小さい方で決まる
$ sysctl net.core.somaxconn
net.core.somaxconn = 4096

# キューあふれの統計は nstat などで確認する
$ nstat -az | grep -E 'ListenOverflows|ListenDrops|TCPBacklogDrop'
TcpExtListenOverflows           107708             0.0
TcpExtListenDrops               107708             0.0
TcpExtTCPBacklogDrop            0                  0.0
```

## TCP

```
# sysctlの各種パラメータの詳細はmanで調べるとよい
$ man tcp 7

# orphaned socket の FIN_WAIT_2 を保持する時間。TIME_WAIT の時間ではない
net.ipv4.tcp_fin_timeout = 30

# [low, pressure, high] からなるベクトル値（単位はページ）
# pressure を超えるとメモリ圧力状態に入り、low を下回ると通常状態に戻る
# high は TCP が使用できるグローバルな上限の目安
net.ipv4.tcp_mem = 383457       511277  766914

# ソケットごとの受信・送信バッファの min / default / max（単位はバイト）
net.ipv4.tcp_rmem = 4096        131072  6291456
net.ipv4.tcp_wmem = 4096        16384   4194304
```

## stat

#### /proc/net/protocols

- 各プロトコルのソケット数、メモリ使用量、pressure 対応可否などを確認する
- `press` が `yes` のプロトコルは、メモリ圧力に対応しています。現在 pressure 状態かどうかだけを示す列ではありません。
- `press` が `NI` の行は、そのプロトコルがこのメモリ圧力機構に対応していないことを示します。
- `memory` はプロトコルが報告するメモリ使用量のカウンタで、表示形式や単位はカーネル実装に依存するため、`tcp_mem` のページ数と単純に比較しないでください。
- TCP がメモリ圧力状態になると、カーネルは状況に応じて以下の処理を行います。
  - TCP ソケットの送信・受信バッファのサイズを制限する
  - 受信の TCP ウィンドウサイズを小さくする（もしくは ZeroWindow にする）
  - 受信キューに入ったセグメントから重複したシーケンス番号をもつセグメントをマージして、空きメモリの確保を試みる（collapse 処理）
  - シーケンス番号順に受信できなかったセグメントを保持する Out of Order キューの SACK 済みセグメントを破棄して空きメモリを確保する（prune 処理）
  - 受信スロースタートの閾値を制限する
- メモリ確保に失敗するなど、さらに厳しい状況では以下の処理が発生する場合があります。
  - セグメントの受信処理で、新規に受信したセグメントを破棄する（Drop）
  - セグメントの送信処理で、メモリを確保できるまでプロセスをブロックして待機させる
  - セグメント受信処理で、Out of Order キューのセグメントを破棄して空きを確保しようとする（SACK renege）
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
TCP       2144     28      36   yes       304   yes  kernel      y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
NETLINK   1064     15      -1   NI       0   no   kernel      n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n

```

#### /proc/net/netstat

- netstat: TCPMemoryPressures
  - TCP のメモリ圧力状態への遷移回数
- netstat: TCPMemoryPressuresChrono
  - TCP がメモリ圧力状態であった累積時間（ミリ秒）
- netstat: OfoPruned
  - Ofo は Out of Order の略で、TCP の Out of Order キューを指す
  - Out of Order キューの prune イベント数。パケット数とは限らない
- netstat: TCPAbortOnMemory
  - TCP oom が発生すると 1 インクリメントされる
- netstat: PruneCalled, RcvPruned
  - 受信キューの prune が呼び出された回数。`tcp_mem` の high 超過だけでなく、ソケット単位の受信メモリ圧力などでも増加します
- netstat: TCPRcvQDrop
  - 受信キューのメモリ不足などにより受信データをドロップした回数。`tcp_mem` の high 超過だけが原因とは限りません
- netstat: TCPAbortFailed
  - TCP oom が発生すると該当のソケットで RST を送りコネクションを切断する
  - この際に、ソケットバッファの割り当てに失敗すると、1 インクリメントされる
    - ソケットバッファの割り当て失敗は、TCP クォータの制限による失敗ではなく、Slab アロケータによる割り当て失敗が原因となる

## オフロード

### IP フラグメンテーションと TCP セグメンテーション

- IP パケットは、送信するリンクの MTU を超えて転送できません。IP 層で大きなパケットを MTU 以下の複数の IP パケットに分割する処理を IP フラグメンテーションと呼びます。
  - IPv4 では、DF（Don't Fragment）フラグが設定されていなければ、途中のルーターがフラグメンテーションすることがあります。分割されたフラグメントは宛先で再構成されます。
  - IPv6 では途中のルーターはフラグメンテーションせず、必要な場合は送信元が Fragment 拡張ヘッダーを使って分割します。通常は PMTUD で送信元が適切なサイズを選びます。
  - IP フラグメンテーションでは、TCP ヘッダーは通常最初のフラグメントにしか含まれません。後続のフラグメントは IP 層で再構成されるまで、独立した TCP セグメントではありません。
- TCP はアプリケーションから受け取ったバイトストリームを、MSS（Maximum Segment Size）などに基づいて複数の TCP セグメントに分割します。TCP セグメンテーションは L4 の処理であり、各セグメントには TCP ヘッダーが含まれます。
  - MSS は SYN/SYN-ACK で広告される値で、通常は経路の MTU から IP ヘッダーと TCP ヘッダーの大きさを引いて決めます。
  - TCP セグメンテーションと IP フラグメンテーションは別の処理です。適切な MSS と PMTUD が機能していれば、TCP セグメントを IP 層でさらにフラグメンテーションする必要はありません。

### 遅延セグメンテーション

- TCP セグメンテーションをプロトコルスタックの早い段階で行うと、後続の処理は小さなセグメントごとに実行する必要があります。そこで Linux は、可能な限り大きな送信単位のまま後段まで処理を進め、必要な地点でセグメンテーションします。この処理を遅延セグメンテーションとして整理できます。
- TSO は、TCP の大きな送信単位を NIC に渡し、NIC が実際に送信する MSS 相当のセグメントへ分割するハードウェア実装です。
- GSO は、NIC が TSO などをサポートしない場合やソフトウェアで分割する場合に、Linux が同様の大きな送信単位を保持して後段で分割する仕組みです。
- 遅延セグメンテーションは MTU を無視して送信する機能ではありません。NIC または GSO が、実際の送信前に MTU 以下のセグメントへ分割します。

- UFO（UDP Fragmentation Offload）は UDP のフラグメンテーションを扱う古いオフロードで、現在の Linux では非推奨です。UDP のセグメンテーションには USO（UDP Segmentation Offload）が使われます。
- LRO（Large Receive Offload）は主に NIC が受信セグメントを結合するハードウェア機能です。GRO（Generic Receive Offload）は Linux がソフトウェアで受信セグメントを結合する仕組みで、LRO の代替または補完として使われます。利用可否や既定値は NIC・ドライバ・カーネルに依存します。
- オフロードの有効状態は `ethtool -k <interface>` で確認できます。TSO や GRO を無効にして切り分けることはできますが、既定値は環境ごとに異なります。
- オフロードの有無にかかわらず、MTU・MSS・PMTUD の不整合があれば通信障害が起きます。TSO を無効にすれば直る場合でも、根本原因が解決したとは限りません。

### メモ

- TSO などのハードウェアオフロードは、NIC・ドライバ・カーネルの組み合わせに依存します。既定値を一律に決めつけず、`ethtool -k <interface>` で確認します。
- MTU や PMTUD の不整合があると、TSO が有効な場合に問題が表面化することがあります。例えば、送信側では MTU 1500 を前提にセグメンテーションされる一方、受信側またはトンネルの先の MTU が 1450 で、PMTUD が正常に機能していないケースです。
- 本来はハンドシェイク時の MSS 広告や PMTUD によって適切なサイズが選ばれますが、実際の環境でそれが機能せず、TSO を無効にすると通信できるようになった事例があります。これは切り分けのための回避策であり、最終的には経路の MTU、MSS、PMTUD、トンネルの MTU を確認します。
- 参考
  - [Segmentation Offloads in the Linux Networking Stack](https://docs.kernel.org/networking/segmentation-offloads.html)
  - [SRv6 ベースのマルチテナンシー環境で起きた TSO 問題とその検証方法 – LINE Developer Meetup #67 フォローアップ記事](https://engineering.linecorp.com/ja/blog/tso-problems-srv6-based-multi-tenancy-environment/)

### トンネルデバイスのオフロード

IPIP, GRE, VXLAN, SRv6 などのトンネルデバイス利用時のオフロードについて

- トンネルでは、カプセル化される元のパケットを内側（inner）、追加されるトンネルヘッダと外側の IP ヘッダを外側（outer）と呼びます。例えば IPIP は outer IP / inner IP、GRE は outer IP / GRE / inner IP、VXLAN・Geneve は outer IP / UDP / tunnel header / inner Ethernet という構造になります。
- 内側の TCP セグメントを先に作ってから一つずつ外側のヘッダを付ける方法もありますが、Linux は GSO skb のままトンネル処理を進め、対応する NIC で最終的にセグメンテーションできる場合があります。これにより、内側の小さなセグメントごとにプロトコルスタックを通す処理を減らせます。
- NIC がトンネルのセグメンテーションに対応している場合は、内側・外側のヘッダ位置などの情報を渡して、NIC が各セグメントに必要なヘッダを付けて送信します。対応していない場合は、GSO がソフトウェアで内側のセグメントを作成し、それぞれを外側のヘッダでカプセル化します。
- トンネルのオーバーヘッドは外側の MTU を消費します。内側の MTU や TCP MSS が大きすぎると、外側の経路でフラグメンテーションやドロップが発生するため、トンネルの MTU と PMTUD も確認します。
- `ethtool -k <interface>` で NIC の対応状況を確認できます。TCP の TSO だけでなく、トンネル用の segmentation と checksum offload がそろっている必要があります。未対応の場合は GSO などのソフトウェア処理にフォールバックしますが、処理位置はトンネルの種類、仮想デバイス、ドライバによって異なります。

```
tx-gre-segmentation: on <= GRE
tx-ipxip4-segmentation: on <= IP in IPv4
tx-ipxip6-segmentation: on <= IP in IPv6
tx-udp_tnl-segmentation: on <= VXLAN, GeneveなどのUDP encap
```

`tx-ipxip4` / `tx-ipxip6` は、それぞれ IP-in-IPv4 / IP-in-IPv6 を表します。`tx-gre-segmentation` は GRE、`tx-udp_tnl-segmentation` は VXLAN や Geneve などの UDP トンネルに対応します。これらの機能名が表示されても、checksum offload や使用する内側のプロトコルまで含めて実際に機能するとは限らないため、ドライバの対応状況を確認してください。SRv6 は通常の IP-in-IPv6 とは構造が異なるため、セグメンテーション対応は実際のカーネル・ドライバのサポートを確認します。

### 二段階トンネルのオフロード

- VM のネットワークがトンネリングを利用し、さらに VM 内の Kubernetes が VXLAN や IPIP を利用する場合などは、トンネルが多重になります。
- ゲスト内のトンネルデバイスで直ちに小さなパケットへ分割されるとは限りません。GSO 情報が vNIC、vhost、vSwitch、物理 NIC まで維持されれば、ホスト側または NIC 側で後から分割されます。途中のデバイスが対応しない場合は、その境界より前で GSO によるソフトウェア分割が行われます。
- Linux のトンネル用 GSO は、一般的に outer / inner の 2 段階のヘッダを前提とします。VXLAN over IPIP のような多重トンネルでは、組み合わせによっては早い段階でソフトウェア分割されるか、オフロード対象外になります。
- HV 側で小さなセグメントへ分割されると、vSwitch や仮想 NIC が処理する skb 数が増えて CPU 負荷が上がる可能性があります。一方、NIC まで大きな GSO skb を渡せても、外側の MTU とトンネルオフロードが整合している必要があります。
- 実際の切り分けでは、ゲストとホスト双方の `ethtool -k`、`ip link` の MTU、vSwitch の設定、キャプチャ上の outer / inner ヘッダ、必要に応じて skb の GSO 状態を確認します。

## DDoS 対策

```
# SYN flood 対策。1 は SYN backlog があふれたときだけ SYN cookie を使う
net.ipv4.tcp_syncookies = 1

# 0 は SYN cookie を無効にする（必要な場合だけ選択）
# net.ipv4.tcp_syncookies = 0

# 2 は常時 SYN cookie を使うテスト用の設定
# net.ipv4.tcp_syncookies = 2

# Smurf 攻撃対策。ブロードキャスト／マルチキャスト宛ての echo・timestamp request を無視する
net.ipv4.icmp_echo_ignore_broadcasts = 1

# ブロードキャストフレームへの不正な ICMP エラー応答に関する警告を抑制する
net.ipv4.icmp_ignore_bogus_error_responses = 1
```

上の `tcp_syncookies` は 0、1、2 のいずれかを選び、同時には設定しません。SYN cookies は正当な接続を保護するためのフォールバックであり、合法的な高負荷を処理するための容量チューニングではありません。

## Bufferbloat

- 不適切なネットワークキューイングや過剰なバッファにより、レイテンシーが悪化する状態
- レイテンシーの悪化や揺らぎは、TCP の輻輳制御やアプリケーションの応答性に影響する

## メモ

```
Linux の qdisc の既定値はカーネルやディストリビューション、デバイスのキュー構成によって異なる
application -> IP stack -> qdisc -> NIC buffer
                              | -- queue -- |

NIC のバッファを大きくするとドロップを減らせる場合がある一方、キュー滞留時間が長くなりレイテンシーが増える場合がある

遅いもの、大きいものは処理に時間がかかる
早いもの、小さいものはその逆 VoIP とか DNS とか

アクティブキュー管理（AQM）
キューの滞留時間や長さに応じて、パケットのドロップや ECN マークを行う

CoDel(Controlled Delay)
パケットの sojourn time（キューに滞留した時間）を測定し、過剰な遅延が続く場合にドロップまたは ECN マークを行う

TCP small queues
Byte Queue Limits
```

## sysctl

- `net.ipv4.conf.{all,default,<interface>}.rp_filter`
  - Reverse Path Filter
  - 受信したパケットの送信元アドレスに対して、逆方向の経路検索を行い、経路が受信 IF と一致しないパケットを破棄するための設定
  - 設定値
    - 0: 無効
    - 1: Strict Mode。最良の逆引き経路が受信した IF である場合だけ許可
    - 2: Loose Mode。送信元への経路がいずれかの IF に存在すれば許可
  - `all` とインターフェース固有の値のうち大きい方が使われるため、変更時は両方を確認する
- `net.ipv4.conf.{all,default,<interface>}.arp_filter`
  - ARP Filter
  - 設定値
    - 0: 受信 IF に関係なく、ホストが保持するアドレスへの ARP に応答し得る
    - 1: 送信元ベースの経路検索で、その IF から応答を返すべき場合に応答する。同一サブネット上の複数 NIC で ARP flux を抑えるには、適切な経路設定も必要
  - ARP の送信元アドレス選択には `arp_announce`、受信制御には `arp_ignore` も関係する

## 複数 NIC 利用時の注意点

- 複数の NIC が別々のセグメントに所属する場合
  - ルーティングテーブルに宛先ごとの経路があれば、その経路に従って通信します。送信元アドレスごとに経路を分ける場合は、policy routing（`ip rule` / `ip route`）も構成します
  - より具体的な経路がない宛先にはデフォルト経路が使われるため、返信が常に受信した NIC から出るとは限りません
  - 非対称ルーティングでは `rp_filter` の Strict Mode が正当なパケットを破棄することがあります
- 複数の NIC が同一のセグメントに所属する場合
  - ARP filter が 0 の場合、別の NIC に設定されたアドレスへの ARP にも応答することがあり、ARP flux が起きる
  - ARP filter が 1 の場合、経路検索の結果に基づいて応答 IF が選ばれる。単純に「受信した NIC から応答する」という意味ではない

## netlink

- netlink は、ユーザー空間とカーネルの各種サブシステムが通信するためのソケットベースの IPC インターフェースです。ネットワーク専用の仕組みではありません
- ネットワークでは `NETLINK_ROUTE`（rtnetlink）が、リンク、アドレス、経路、近隣エントリ、qdisc などの取得・変更に使われます
- `ip` コマンドや `ss` コマンドも netlink を利用して、状態の取得や操作を行います
- 参考
  - [`netlink(7)` — Linux manual page](https://man7.org/linux/man-pages/man7/netlink.7.html)
  - [Introduction to Netlink — The Linux Kernel documentation](https://docs.kernel.org/userspace-api/netlink/intro.html)
  - [Go による実装: netlink](https://github.com/vishvananda/netlink)

## Reference

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

## 仮想ネットワークデバイスの参考

- [Introduction to Linux interfaces for virtual networking](https://developers.redhat.com/blog/2018/10/22/introduction-to-linux-interfaces-for-virtual-networking/)
