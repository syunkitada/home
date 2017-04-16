# Network tools

## ping
* レイテンシを確認する
```
$ ping google.co.jp
PING google.co.jp (216.58.197.195) 56(84) bytes of data.
64 bytes from nrt13s48-in-f195.1e100.net (216.58.197.195): icmp_seq=1 ttl=54 time=3.73 ms
64 bytes from nrt13s48-in-f195.1e100.net (216.58.197.195): icmp_seq=2 ttl=54 time=4.13 ms
```

## traceroute
* 通信経路を確認する
* レイテンシを確認する
```
$ traceroute google.co.jp
```

## mtr
* mtrは連続でtracerouteし、その結果を描画し続けます
* 通信経路のレイテンシやLoss率を見たい場合に利用します
```
# loss率などがわかる
$ mtr  192.168.122.102
                                                                                                                                                                                                    Packets               Pings
 Host                                                                                                                                                                                             Loss%   Snt   Last   Avg  Best  Wrst StDev
 1. 192.168.122.102                                                                                                                                                                                0.0%     2    0.6   0.5   0.4   0.6   0.0
```


## tcpdump
```
$ sudo tcpdump -i eth0 -w /tmp/out.tcpdump


$ sudo tcpdump -i [device] -X
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
* socket statistics
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



## ip
```
# ルーティングテーブルの確認
$ ip route
default via 192.168.122.1 dev eth0
192.168.122.0/24 dev eth0  proto kernel  scope link  src 192.168.122.102


```

## arp
* arpテーブルの確認に利用します
* L2の通信ができない場合や、L2に他IPが存在しないことを確認するために利用します
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


## nicstat
* rpmなし(野良rpmはある）
```
$ nicstat 1
    Time      Int   rKB/s   wKB/s   rPk/s   wPk/s    rAvs    wAvs %Util    Sat
13:34:48     eth0    3.51    0.35    2.49    1.75  1443.7   205.8  0.00   0.50
13:34:48       lo    0.00    0.00    0.01    0.01   105.2   105.2  0.00   0.00
    Time      Int   rKB/s   wKB/s   rPk/s   wPk/s    rAvs    wAvs %Util    Sat
13:34:49     eth0    0.06    0.10    1.00    1.00   66.00   102.0  0.00   0.00
13:34:49       lo    0.00    0.00    0.00    0.00    0.00    0.00  0.00   0.00
```


## iptraf
コマンドライン上でGUIみたいなインターフェイスで統計が見れる
``` bash
$ iptraf-ng
 iptraf-ng 1.1.4
l TCP Connections (Source Host:Port) qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq Packets qqqqqqqqqqqqqqqqqqqqqqqqqq Bytes qqqqqqqqqqq Flag qqqqqqqqq Iface qqqqqqqqqqqqqqqqqqqqqqk
xl192.168.122.101:22                                                                                                                      >    1751                           377324             -PA-           eth0                        x
xm192.168.122.1:57568                                                                                                                     >    1751                            91232             --A-           eth0                        x
xl192.168.122.1:53068                                                                                                                     >      62                             4100             --A-           eth0                        x
...
```



## ethtool
Mostly interface tuning; som stats
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
