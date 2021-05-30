# Network tools

## ping

- レイテンシを確認する

```
$ ping google.co.jp
PING google.co.jp (216.58.197.195) 56(84) bytes of data.
64 bytes from nrt13s48-in-f195.1e100.net (216.58.197.195): icmp_seq=1 ttl=54 time=3.73 ms
64 bytes from nrt13s48-in-f195.1e100.net (216.58.197.195): icmp_seq=2 ttl=54 time=4.13 ms
```

## traceroute

- 通信経路を確認する
- レイテンシを確認する

```
$ traceroute google.co.jp
```

## mtr

- mtr は連続で traceroute し、その結果を描画し続けます
- 通信経路のレイテンシや Loss 率を見たい場合に利用します

```
# loss率などがわかる
$ mtr  192.168.122.102
                                                                                                                                                                                                    Packets               Pings
 Host                                                                                                                                                                                             Loss%   Snt   Last   Avg  Best  Wrst StDev
 1. 192.168.122.102                                                                                                                                                                                0.0%     2    0.6   0.5   0.4   0.6   0.0
```

## netstat

```
# ネットワークコネクションをすべて表示する
$ netstat -an

# Webサーバなどのコネクションが詰まると、大きめの数値として出てくる
$ netstat -an | wc
    1143

# 特定のコネクションステータスだけ抽出
$ netstat -an | grep ESTABLISHED | wc
    1028

# 各ネットワークプロトコルのstatisticsを表示する
$ netstat -s
...
Tcp:
    210 active connections openings
    31 passive connection openings
    0 failed connection attempts
    1 connection resets received
    2 connections established
    30741 segments received
    27367 segments send out
    17 segments retransmited
    0 bad segments received.
    2 resets sent
...

# インターフェイスのエラーやドロップを確認する
$ netstat -i
Kernel Interface table
Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
eth0      1500   149313      0  11707 0        118987      0      0      0 BMRU
lo       65536        6      0      0 0             6      0      0      0 LRU

# 各プロトコルの詳細を表示する
$ netstat -p
```

## ss

- socket statistics

```
# -m: show socket memory usage
# -o: show timer information
# -p: show process using socket
$ sudo ss -mop
Netid State      Recv-Q Send-Q                                                                     Local Address:Port                                                                                      Peer Address:Port
...
tcp   CLOSE-WAIT 272    0                                                                              127.0.0.1:50595                                                                                        127.0.0.1:http
         skmem:(r2304,rb1061296,t0,tb2626560,f1792,w0,o0,bl0)
tcp   ESTAB      0      4432                                                                     192.168.122.101:ssh                                                                                      192.168.122.1:57568                 timer:(on,009ms,0)
         skmem:(r0,rb369280,t0,tb87040,f15200,w5280,o0,bl0)
tcp   FIN-WAIT-1 0      1                                                                       ::ffff:127.0.0.1:http                                                                                  ::ffff:127.0.0.1:50594                 timer:(on,198ms,0)
         skmem:(r0,rb1061488,t0,tb2626560,f2816,w1280,o0,bl0)
tcp   FIN-WAIT-1 0      1                                                                       ::ffff:127.0.0.1:http                                                                                  ::ffff:127.0.0.1:50595                 timer:(on,198ms,0)
         skmem:(r0,rb1061488,t0,tb2626560,f2816,w1280,o0,bl0)

# socketのサマリを表示
$ ss -s
Total: 178 (kernel 0)
TCP:   9 (estab 2, closed 1, orphaned 0, synrecv 0, timewait 0/0), ports 0

Transport Total     IP        IPv6
*         0         -         -
RAW       0         0         0
UDP       2         1         1
TCP       8         5         3
INET      10        6         4
FRAG      0         0         0
```

## ip -a

```bash
$ ip a show dev enp31s0
2: enp31s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 70:85:c2:b7:a2:b6 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.121/24 brd 192.168.10.255 scope global noprefixroute enp31s0
     valid_lft forever preferred_lft forever
```

- mtu 1500
  - 最大の IP パケットサイズ
  - これにフレームヘッダ(14 bytes)と FCS(4 byte)が加算されてフレームが完成
- qdisc fq_codel
  - qdisc は Queueing Discipline の略
  - fq_codel は、スケジューリング方式の一つ
    - Fair/Flow Queueing + Codel の略
    - https://www.bufferbloat.net/projects/codel/wiki/
  - tc コマンドで変更可能
- qlen 1000
  - 送信キューの長さ
  - 大きくしすぎる bufferbloat などの問題が発生するので注意
    - bufferbloat とは送信パケットを過剰にバッファリングするとその分パケットが遅延しやすくなる問題
    - 優先度の高い通信は送信バッファを小さくするという対策もある

## ip -s link

```bash
$ ip -s link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
RX: bytes  packets  errors  dropped overrun mcast
1866314030 4034006  0       0       0       0
TX: bytes  packets  errors  dropped carrier collsns
1866314030 4034006  0       0       0       0
2: enp31s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
link/ether 70:85:c2:b7:a2:b6 brd ff:ff:ff:ff:ff:ff
RX: bytes  packets  errors  dropped overrun mcast
2457569    6821     0       0       0       2186
TX: bytes  packets  errors  dropped carrier collsns
1049875    4730     0       0       0       0
```

- errors
  - Ethernet の CRC エラーなど、NIC 上で処理できなかったパケット数
  - ケーブルの破損等
- dropped
  - 意図的なドロップ
  - サポートしてないフレーム(IPv6 をを無効化している状態でやってきた IPv6 パケットなど)
- overrun
  - RX ring buffer の容量が足りずに破棄されたパケット数
- mcast
  - マルチキャスト通信を正常に受信した数
- carrier
  - NIC 毎で何らかの問題（ケーブルの接触不良）が生じて送信できなかったパケット数
- collsns
  - コリジョンを検知した（ジャム信号を送った）回数

## ip rule

- ポリシールール
  - RPDB(routing policy database)によって管理され、ルーティングに利用される
  - ポリシールールは、セレクタとアクションからなる
    - セレクタ: アクションを実施したいパケットの条件を記述する
    - アクション: 実行したいことを記述する
      - 特定の table から経路情報御を lookup したり、NAT を実施することもできる
  - ルーティングの流れ
    - 優先度(priority)の小さい順で、RPDB 内のポリシールールを一つづつ見ていく
    - ルールのセレクタにパケットが合致する場合、アクションを実施する
    - アクションの実行に成功(例えば経路情報を取得）できれば、RPDB の lookup は終了
    - セレクタに合致しないか、アクションの実行に失敗すれば、次のポリシールールを見る

```
$ ip rule
0:      from all lookup local
32766:  from all lookup main
32767:  from all lookup default

```

## ip route

```
# routingテーブルの確認
$ ip route show
default via 192.168.10.1 dev enp31s0 proto static metric 100
169.254.0.0/16 dev enp31s0 scope link metric 1000
169.254.32.1 dev com-0-ex scope link
169.254.32.2 dev com-1-ex scope link


# 特定ポリシールールのrouteの確認
$ ip route show table 0
default via 192.168.10.1 dev enp31s0 proto static metric 100
169.254.0.0/16 dev enp31s0 scope link metric 1000


# 全ポリシーのroute を確認
$ ip route show table 0
default via 192.168.10.1 dev enp31s0 proto static metric 100
169.254.0.0/16 dev enp31s0 scope link metric 1000


# 特定IP宛てのルートを取得する
$ ip route get 192.168.101.4
192.168.101.4 dev com-3-ex src 192.168.10.121 uid 1000
    cache

```

## ip neigh

```
$ ip neigh
192.168.10.1 dev enp31s0 lladdr c0:25:a2:dd:db:b8 STALE
192.168.101.4 dev com-3-ex lladdr 0e:3f:7a:f1:ef:9d STALE
169.254.32.4 dev com-3-ex lladdr 0e:3f:7a:f1:ef:9d STALE
192.168.100.2 dev com-0-ex lladdr b6:b6:3e:42:b2:0e STALE
169.254.32.5 dev com-4-ex lladdr 9a:34:89:fe:f2:03 STALE
169.254.32.3 dev com-2-ex lladdr 46:b4:3b:3e:d0:f7 STALE
169.254.32.1 dev com-0-ex lladdr b6:b6:3e:42:b2:0e STALE
192.168.10.101 dev enp31s0 lladdr 94:65:9c:6e:fd:39 DELAY
192.168.101.3 dev com-4-ex lladdr 9a:34:89:fe:f2:03 STALE
192.168.101.2 dev com-2-ex lladdr 46:b4:3b:3e:d0:f7 STALE
fe80::10ff:fe02:208b dev enp31s0 lladdr 02:00:10:02:20:8b router STALE

```

## arp

- arp テーブルの確認に利用します
- L2 の通信ができない場合や、L2 に他 IP が存在しないことを確認するために利用します

```
# arpテーブルのキャッシュ確認
$ arp
Address                  HWtype  HWaddress           Flags Mask            Iface
192.168.122.101          ether   00:16:3e:09:6e:0d   C                     eth0
gateway                  ether   fe:16:3e:09:6e:0d   C                     eth0

# 特定IPのキャッシュを確認
$ arp 192.168.122.101
Address                  HWtype  HWaddress           Flags Mask            Iface
192.168.122.101          ether   00:16:3e:09:6e:0d   C                     eth0

# キャッシュにない場合はno entryが表示される
$ arp 192.168.122.103
192.168.122.103 (192.168.122.103) -- no entry

# pingを飛ばすと、arp解決してキャッシュに乗る
$ ping 192.168.122.103
PING 192.168.122.103 (192.168.122.103) 56(84) bytes of data.
64 bytes from 192.168.122.103: icmp_seq=1 ttl=64 time=0.644 ms
64 bytes from 192.168.122.103: icmp_seq=2 ttl=64 time=0.325 ms
^C
--- 192.168.122.103 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1000ms
rtt min/avg/max/mdev = 0.325/0.484/0.644/0.161 ms

$ arp 192.168.122.103
Address                  HWtype  HWaddress           Flags Mask            Iface
192.168.122.103          ether   00:16:3e:25:a0:c6   C                     eth0
```

## iptraf

- コマンドライン上で GUI みたいなインターフェイスで統計が見れる

```bash
$ iptraf-ng
 iptraf-ng 1.1.4
l TCP Connections (Source Host:Port) qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq Packets qqqqqqqqqqqqqqqqqqqqqqqqqq Bytes qqqqqqqqqqq Flag qqqqqqqqq Iface qqqqqqqqqqqqqqqqqqqqqqk
xl192.168.122.101:22                                                                                                                      >    1751                           377324             -PA-           eth0                        x
xm192.168.122.1:57568                                                                                                                     >    1751                            91232             --A-           eth0                        x
xl192.168.122.1:53068                                                                                                                     >      62                             4100             --A-           eth0                        x
...
```

## ethtool

- Mostly interface tuning; som stats

```
$ sudo ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Supported pause frame use: No
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        MDI-X: on (auto)
        Supports Wake-on: pumbg
        Wake-on: g
        Current message level: 0x00000007 (7)
                               drv probe link
        Link detected: yes
```

## lsof -i

- lsof 自体はプロセスが開いているファイル情報を収集するためのツール
- -i オプションでソケットの情報を表示することができる

```
$ sudo lsof -i
[sudo] password for owner:
COMMAND     PID            USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
systemd-r   490 systemd-resolve   12u  IPv4   18977      0t0  UDP localhost:domain
systemd-r   490 systemd-resolve   13u  IPv4   18978      0t0  TCP localhost:domain (LISTEN)
cupsd       740            root    6u  IPv6   27913      0t0  TCP ip6-localhost:ipp (LISTEN)
cupsd       740            root    7u  IPv4   27914      0t0  TCP localhost:ipp (LISTEN)
```
