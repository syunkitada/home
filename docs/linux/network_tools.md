# Network tools

## traceroute
```
# ドメインへのrouteを調べる
$ traceroute google.co.jp
```

## mtr
```
# 連続でtracerouteする
# loss率などがわかる
$ mtr  google.co.jp
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

# 各プロトコルの詳細を表示する
$ netstat -p
```

## ip



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


## ss
* socket statistics
```
# -m: show socket memory usage
# -o: show timer information
# -p: show process using socket
$ ss -mop
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
