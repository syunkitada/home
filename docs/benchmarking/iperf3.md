# iperf3

## Install
``` bash
$ sudo yum install iperf3
```

## Server側
```
# -s: サーバモードで起動
# -V: 詳細なレポートを出す
$ sudo iperf3 -sV
iperf 3.1.6
Linux benchmark-2-hostname 3.10.0-327.el7.x86_64 #1 SMP Thu Nov 19 22:10:57 UTC 2015 x86_64
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
```


## Client側
``` bash
# -V: 詳細なレポートを出す
# -t: 実行時間（秒)
# -l: パケットサイズ、defaultは128K
$ iperf3 -c 192.168.122.102 -t 3 -V -l 128K
iperf 3.1.6
Linux benchmark-1-hostname 3.10.0-327.el7.x86_64 #1 SMP Thu Nov 19 22:10:57 UTC 2015 x86_64
Control connection MSS 1448
Time: Sun, 02 Apr 2017 10:40:15 GMT
Connecting to host 192.168.122.102, port 5201
      Cookie: benchmark-1-hostname.1491129615.6758
      TCP MSS: 1448 (default)
[  4] local 192.168.122.101 port 42374 connected to 192.168.122.102 port 5201
Starting Test: protocol: TCP, 1 streams, 131072 byte blocks, omitting 0 seconds, 3 second test
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec  1.70 GBytes  14.6 Gbits/sec    0   3.05 MBytes
[  4]   1.00-2.00   sec  1.72 GBytes  14.8 Gbits/sec    0   3.05 MBytes
[  4]   2.00-3.00   sec  1.72 GBytes  14.8 Gbits/sec    0   3.05 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
Test Complete. Summary Results:
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-3.00   sec  5.14 GBytes  14.7 Gbits/sec    0             sender
[  4]   0.00-3.00   sec  5.14 GBytes  14.7 Gbits/sec                  receiver
CPU Utilization: local/sender 26.0% (1.0%u/25.2%s), remote/receiver 26.8% (4.5%u/22.5%s)
snd_tcp_congestion cubic
rcv_tcp_congestion cubic

iperf Done.
```

## 結果の見方
* iperfのClient, Serverが性能を出し切れるかによっても結果も異なってくるので注意する
    * -Z: Zerocopyを有効にする
    * -A: Affinityを設定する（できればカーネルでisolしたものを使うとよいかも)
* Transfer（送信パケットサイズ）
* Bandwidth(スループット)
    * -l で指定できるパケットサイズによって結果は異なる
    * ショートパケット有利、ラージパケット有利な環境などあるので、いろいろなパターンで測定すべき
* Retr(TCPの再送回数)
    * 多いと問題
* CPU Utilization
    * CPUの使用率が高いと、それが原因で結果がサチるので確認する
