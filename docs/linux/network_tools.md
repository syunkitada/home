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
