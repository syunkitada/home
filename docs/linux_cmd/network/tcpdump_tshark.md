# tcpdump & tshark

## tcpdump

- L2 レイヤでパケットを取得するためのツール
- 基本的に L2 や L3 のレイヤでの問題を切り分けや、ネットワークの挙動の確認に利用される
- ある程度目的のパケットが分ってる場合は、オプションを付けて特定のプロトコルや宛先やポートを指定して、標準出力にキャプチャ結果を出力するとよい

```
# 利用可能なインターフェイス一覧を表示
$ tcpdump -D

# デバイスでフィルタリング
$ sudo tcpdump -i [device]

# 全デバイスでキャプチャする
# -i なしだと適当なデバイスでキャプチャされるのでanyか、何かしらのデバイスを指定するとよい
$ sudo tcpdump -i any ...

# ホスト名でフィルタリング
$ sudo tcpdump host [hostname]

# SrcIP, DstIP, Portを指定してのフィルタリング
$ sudo tcpdump -i [device] src [ip1] and dst [ip2] and dst port [port]

# ネットワークアドレスでフィルタリング
$ sudo tcpdump net [network addres: eg.192.168.1.0/24]

# 特定のPortを含まないフィルタリング
$ sudo tcpdump not port [port]

# プロトコルでフィルタリング
$ sudo tcpdump [protocol]
# ex.
# $ sudo tcpdump icmp
# tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
# listening on enp31s0, link-type EN10MB (Ethernet), capture size 262144 bytes
# 14:51:31.521513 IP 192.168.10.101 > owner-desktop: ICMP echo request, id 4809, seq 122, length 64
# 14:51:31.521563 IP owner-desktop > 192.168.10.101: ICMP echo reply, id 4809, seq 122, length 64
```

### tcpdump の表示形式を変更する

```
# キャプチャ結果のVerbose表示
$ sudo tcpdump -v port 80

# キャプチャ結果のAscii表示
# HTMLなどの中身を見たい場合はこれが便利
$ sudo tcpdump -A port 80

# キャプチャ結果のHexとAscii表示
$ sudo tcpdump -X port 80

# キャプチャ結果をL2モードで表示
$ sudo tcpdump -e port 80
```

### tcpdump をファイルに保存して後で解析する

- ネットワークでなんらかの問題がある場合に、問題をの切り分けを行いたい場合には、ファイルにパケットをキャプチャしておいて後で解析することがよくある
- 簡単な解析であれば tcpdump でやる場合が多いが、後述する tshark を使うとより解析がしやすい

```
# 愚直にやるなら以下だが、ある程度目的のパケットが絞れてる場合は、-iなどでフィルタリングするとよい
$ sudo tcpdump -w [filepath]

# 本番環境で実行する場合はcountを指定してディスク容量を使いつぶさないように気を付ける
# パケット数で制限を掛ける
$ sudo tcpdump -w /tmp/testdump -c 10
# ファイルサイズ(MB)で制限を掛ける
$ sudo tcpdump -w /tmp/testdump -C 1
# 時間で制限を掛ける
$ sudo tcpdump -w /tmp/testdump -G 1

# tcpdumpで読み込んで、解析する
$ sudo tcpdump -r [filepath]
```

## tshark

```
$ sudo apt-get install tshark
```

```
# パケットをファイルキャプチャする
$ sudo tcpdump -i enp31s0 -w /tmp/tcpdump.out
```

```
# 基本的な使い方はフィルタリングして目的の(不正な、怪しい)パケットを見つける
# -n を付けると名前解決してくれる
$ tshark -nr /tmp/tcpdump.out 'tcp.srcport==80'
4   3.976424 192.168.10.121 → 192.168.10.101 TCP 66 80 → 50627 [SYN, ACK] Seq=0 Ack=1 Win=64240 Len=0 MSS=1460 SACK_PERM=1 WS=128
7   3.983913 192.168.10.121 → 192.168.10.101 TCP 54 80 → 50627 [ACK] Seq=1 Ack=79 Win=64256 Len=0
8   3.984941 192.168.10.121 → 192.168.10.101 TCP 208 HTTP/1.0 200 OK  [TCP segment of a reassembled PDU]
9   3.985013 192.168.10.121 → 192.168.10.101 HTTP 938 HTTP/1.0 200 OK  (text/html)
```

### TCP 関連の絞り込み

```
# srcportで絞り込む
$ tshark -r /tmp/tcpdump.out 'tcp.srcport==80'

# dstportで絞り込む
$ tshark -r /tmp/tcpdump.out 'tcp.dstport==80'


# synパケットで絞り込む
$ tshark -r /tmp/tcpdump.out 'tcp.flags.syn==1'

# TCPZeroWindowで絞り込む
# ZeroWindowは、受信側のTCPバッファが詰まっていている場合に、送信側にこれ以上送らないように教えるために、このフラグを立てて送信側に送信される
$ tshark -r /tmp/tcpdump.out 'tcp.window_size==0'

# resetフラグが出てる場合は、以下のパターンがある
# 受信側が受信できないポートへ通信を受信したときに送信側にこのフラグを立てて返す
# 受信側に自身のIPアドレス宛でないパケットを受信したときに送信側にこのフラグを立てて返す
# 送信側が受信側からTCPZeroWindowを何度か受け取って、これ以上送信できないと判断したときにこのフラグを立てて受信側に送信する
$ tshark -r /tmp/tcpdump.out 'tcp.flags.reset==1'
```

### IP 関連の絞り込み

```
# srcipで絞り込む
$ tshark -r /tmp/tcpdump.out 'ip.srcip=192.168.1.1'

# dstipで絞り込む
$ tshark -r /tmp/tcpdump.out 'ip.srcip=192.168.1.2'

# パケットサイズで絞り込む
$ tshark -r /tmp/tcpdump.out 'ip.len>100'

# パケットサイズで絞り込む
$ tshark -r /tmp/tcpdump.out 'ip.len==1500'
```

### ARP 関連の絞り込み

```
# arp要求
$ tshark -r /tmp/tcpdump.out 'arp.opcode==1'

# arp応答
$ tshark -r /tmp/tcpdump.out 'arp.opcode==2'
```

### ICMP

```
# icmp request
$ tshark -r /tmp/tcpdump.out 'icmp.type==8'

# icmp reply
$ tshark -r /tmp/tcpdump.out 'icmp.type==0'

# icmp host unreachable
$ tshark -r /tmp/tcpdump.out 'icmp.type==3' and 'icmp.code==1'

# icmp port unreachable
$ tshark -r /tmp/tcpdump.out 'icmp.type==3' and 'icmp.code==3'
```

### Frame

```
# frameの時間で絞り込む
$ tshark -r /tmp/tcpdump.out 'frame.time >= "2020-09-22 12:00:00"'

# frameの番号で絞り込む
$ tshark -r /tmp/tcpdump.out 'frame.number >= 10 and frame.number < 20'
```

```
# 時間の表示
$ tshark -r /tmp/tcpdump.out -ta [options]

# Frame間の時間を差分にして表示
$ tshark -r /tmp/tcpdump.out -td

# 表示するフィールドを指定する
$ tshark -r /tmp/tcpdump.out -td -T fields -e frame.number -e ip.src -e tcp.flags.syn -e tcp.flags.ack
```

### 統計情報

```
# 全プロトコルの統計情報を表示
$ tshark -qr /tmp/tcpdump.out -z io,phs

===================================================================
Protocol Hierarchy Statistics
Filter:

eth                                      frames:26 bytes:4062
  ip                                     frames:26 bytes:4062
    tcp                                  frames:26 bytes:4062
      ssh                                frames:3 bytes:486
      http                               frames:4 bytes:2140
        data-text-lines                  frames:2 bytes:1876
          tcp.segments                   frames:2 bytes:1876
===================================================================


# httpのみに限定して統計情報を表示
$ tshark -qr /tmp/tcpdump.out -z io,phs,http

===================================================================
Protocol Hierarchy Statistics
Filter: http

eth                                      frames:4 bytes:2140
  ip                                     frames:4 bytes:2140
    tcp                                  frames:4 bytes:2140
      http                               frames:4 bytes:2140
        data-text-lines                  frames:2 bytes:1876
          tcp.segments                   frames:2 bytes:1876
===================================================================


# IPアドレスのconversionの表示
$ tshark -qr /tmp/tcpdump.out -z conv,ip
================================================================================
IPv4 Conversations
Filter:<No Filter>
                                               |       <-      | |       ->      | |     Total     |    Relative    |   Duration   |
                                               | Frames  Bytes | | Frames  Bytes | | Frames  Bytes |      Start     |              |
192.168.10.101       <-> 192.168.10.121            13      3126      13       936      26      4062     0.000000000         6.8361
================================================================================


# TCPのconversion表示
$ tshark -qr /tmp/tcpdump.out -z conv,tcp
================================================================================
TCP Conversations
Filter:<No Filter>
                                                           |       <-      | |       ->      | |     Total     |    Relative    |   Duration   |
                                                           | Frames  Bytes | | Frames  Bytes | | Frames  Bytes |      Start     |              |
192.168.10.101:50627       <-> 192.168.10.121:80                5      1320       5       378      10      1698     3.976361000         0.0231
192.168.10.101:50628       <-> 192.168.10.121:80                5      1320       5       378      10      1698     6.789281000         0.0111
192.168.10.101:49254       <-> 192.168.10.121:22                2       308       2       120       4       428     3.985103000         2.8510
192.168.10.101:49249       <-> 192.168.10.121:22                1       178       1        60       2       238     0.000000000         0.0417
================================================================================


# TCPのconcersion表示(portでフィルタリング, ipなどでもフィルタリングできる)
$ tshark -qr /tmp/tcpdump.out -z conv,tcp,tcp.port==80
================================================================================
TCP Conversations
Filter:tcp.port==80
                                                           |       <-      | |       ->      | |     Total     |    Relative    |   Duration   |
                                                           | Frames  Bytes | | Frames  Bytes | | Frames  Bytes |      Start     |              |
192.168.10.101:50627       <-> 192.168.10.121:80                5      1320       5       378      10      1698     3.976361000         0.0231
192.168.10.101:50628       <-> 192.168.10.121:80                5      1320       5       378      10      1698     6.789281000         0.0111
================================================================================


# HTTPの統計表示
$ tshark -qr /tmp/tcpdump.out -z http,stat
===================================================================
HTTP Statistics
* HTTP Status Codes in reply packets
    HTTP 200 OK
* List of HTTP Request methods
          GET 2
===================================================================


# ICMPの統計情報表示
$ tshark -qr /tmp/tcpdump.out -z icmp,srt
==========================================================================
ICMP Service Response Time (SRT) Statistics (all times in ms):
Filter: <none>

Requests  Replies   Lost      % Loss
0         0         0           0.0%

Minimum   Maximum   Mean      Median    SDeviation     Min Frame Max Frame
0.000     0.000     0.000     0.000     0.000          0         0
==========================================================================
```

### tshark を tcpdump のように使う

```
# リアルタイムにフィルタリングして表示する
$ sudo tshark -i enp31s0 -Y 'tcp.dstport==80'
Running as user "root" and group "root". This could be dangerous.
Capturing on 'enp31s0'


# ファイルに書き込む
$ sudo tshark -i enp31s0 -w /tmp/tshark.cap
```
