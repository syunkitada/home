# Network


## NAPI対応の受信処理(Kernel2.6以降)
* Kernel2.6ではデバイスドライバに対してNAPI(New API)と呼ばれる新しい受信APIが提供されるようになった。
* ネットワークインタフェースで受信したパケットは、デバイスドライバのH/W割り込み処理処理で刈り取られる。
* ハードウェア割り込みが発生すると、H/W割り込みを禁止してポーリング処理によってデバイスの受信バッファからパケットを取り出していく。
* バッファが空になって受信処理が完了すると、割り込みを再度許可状態にして、次の受信が発生するのを待つようにしている。

参考
* http://wiki.bit-hive.com/linuxkernelmemo/pg/%C1%F7%BC%F5%BF%AE
* http://syuu1228.hatenablog.com/entry/20101015/1287095708


## ソケットインタフェース
* TCPソケットはlisten()関数の第二引数backlogに指定した数の、完全に確立された接続要求を待ち受けることができるキューを作成します。
* キューがいっぱいになった状態で新たに接続を受け取ると、サーバはECONNREFUSEDを返します。
* 下位層のプロトコルが再送をサポートしていれば、ECONNREFUSEDは無視され、リトライが成功するかもしれません。
* net.core.somaxconnは、TCPソケットが受け付けた接続要求を格納する、キューの最大長です。
* backlog > net.core.somaxconnのとき、キューの大きさは暗黙にnet.core.somaxconnに切り詰められます。

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
* http://wiki.bit-hive.com/linuxkernelmemo/pg/listen%20backlog%20%A1%DA3.6%A1%DB




プロトコルスタック
ネットワークデバイス
netfilter
コネクション
るーてキング
パケットスケジューラー
3ウェイハンドシェイク
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

## DDOS対策
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

| ProtocolStuck |  Netfilter |

| NetDevice (Driverを抽象化したDevice) |

| Device Drivers |

| NetworkDevice(NIC)



## Refarence
* [Linuxカーネルメモ 送受信](http://wiki.bit-hive.com/linuxkernelmemo/pg/%C1%F7%BC%F5%BF%AE)
* [ネットワーク関係記事まとめ 2013/06](http://syuu1228.hatenablog.com/entry/20130603/1370300554)
