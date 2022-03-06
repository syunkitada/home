## ネットワーク

### Cloud Load Balancing

- https://cloud.google.com/load-balancing/
- デフォルトのドメイン名は、.appspot.com で、複数のサービスで同一の IP が使われている
- 単一のエニーキャスト IP を複数のサービスで共有している
- ワイルドカードで A レコードも登録してあるが、各ドメインごとにも A レコードが設定されているので、後者が優先される
  - カスタムドメインも設定できる
- 1e100.net で、ドメイン名からロードバランスしてると思われる(L4 + L7 ?)
- 1e100.net とは？
  - 「google」は、数学用語の「googol」よりラリー・ペイジが命名したもので、「googol」とは 10100 を表す単位
  - この 10100 を 1e100 とあらわして、1e100.net
  - Google → googol → 10100 → 1e100 → 1e100.net
- App Engine へのリクエストは、セキュリティ上の理由から Request, Response の Header は前段の L7 プロキシ?によって書き換えられる
  - https://cloud.google.com/appengine/docs/standard/go/reference/request-response-headers#request_headers

```
# dig results
*.appspot.com. 288 IN A 172.217.25.84
hoge.appspot.com. 210 IN A 172.217.31.148
hoge1.appspot.com. 291 IN A 172.217.24.148
hoge2.appspot.com. 228 IN A 216.58.197.180
piyo.appspot.com. 278 IN A 172.217.25.84
piyo1.appspot.com. 292 IN A 172.217.31.180
piyo2.appspot.com. 285 IN A 172.217.31.180
```

```
$ sudo traceroute -T -p 443 172.217.25.84
traceroute to 172.217.25.84 (172.217.25.84), 30 hops max, 60 byte packets
...
 4  softbank221111178241.bbtec.net (221.111.178.241)  3.591 ms  4.195 ms  4.220 ms // Softbank
 5  10.9.203.2 (10.9.203.2)  4.621 ms  4.569 ms  5.262 ms // トランジット
 6  209.85.149.253 (209.85.149.253)  4.823 ms  3.910 ms  4.171 ms  // Google
 7  209.85.245.139 (209.85.245.139)  4.110 ms 209.85.245.167 (209.85.245.167)  4.034 ms  4.015 ms
 8  108.170.233.77 (108.170.233.77)  3.576 ms 108.170.233.79 (108.170.233.79)  3.381 ms  3.409 ms
 9  nrt13s50-in-f84.1e100.net (172.217.25.84)  3.254 ms  3.485 ms  3.190 ms

$ sudo traceroute -T -p 443 172.217.31.148
traceroute to 172.217.31.148 (172.217.31.148), 30 hops max, 60 byte packets
...
 6  209.85.149.253 (209.85.149.253)  4.703 ms  3.810 ms  4.050 ms
 7  209.85.245.167 (209.85.245.167)  5.745 ms 209.85.245.139 (209.85.245.139)  2.848 ms 209.85.245.167 (209.85.245.167)  4.883 ms
 8  74.125.251.237 (74.125.251.237)  3.551 ms  3.424 ms 74.125.251.235 (74.125.251.235)  3.708 ms
 9  nrt20s08-in-f20.1e100.net (172.217.31.148)  2.932 ms  3.070 ms  3.104 ms


$ sudo traceroute -T -p 443 172.217.31.180
traceroute to 172.217.31.180 (172.217.31.180), 30 hops max, 60 byte packets
...
 6  209.85.149.253 (209.85.149.253)  4.101 ms  3.850 ms  3.717 ms
 7  209.85.245.113 (209.85.245.113)  6.019 ms 74.125.252.119 (74.125.252.119)  3.822 ms  3.858 ms
 8  209.85.248.113 (209.85.248.113)  4.225 ms  4.343 ms 209.85.253.109 (209.85.253.109)  4.413 ms
 9  nrt12s22-in-f20.1e100.net (172.217.31.180)  3.757 ms  3.915 ms  3.969 ms
```

```
# google.com への Traceroute
google.com.             54      IN      A       172.217.27.78

$ sudo traceroute -T -p 443 172.217.27.78
...
 6  209.85.149.253 (209.85.149.253)  4.075 ms  3.443 ms  2.960 ms
 7  74.125.252.119 (74.125.252.119)  3.322 ms 209.85.245.113 (209.85.245.113)  5.029 ms 74.125.252.119 (74.125.252.119)  3.786 ms
 8  108.170.236.7 (108.170.236.7)  3.822 ms  4.408 ms  4.446 ms
 9  nrt12s15-in-f78.1e100.net (172.217.27.78)  4.763 ms  4.487 ms  4.689 ms
```

## Latency

- 低負荷時の Latency は 2ms
- Src は東京, Region は asia-east2、Environment は Go 1.12

```
$ time curl https://xxxx.appspot.com/
Hello, World!curl https://xxxx.appspot.com/  0.02s user 0.00s system 4% cpu 0.543 total
```

## Cloud Storage による Static ファイルの管理

- https://cloud.google.com/appengine/docs/standard/go/serving-static-files
- Always Free だとリージョンが、us-east1、us-west1、us-central1 に限定される(2020/1/5 時点)
- アプリケーションからダイレクトで返す場合は、app.yaml に定義する
- リクエストの制限に引っかかりそうなら Cloud Strage を利用すればよい
