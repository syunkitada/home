# wrk

使用感はabに似ている。
また、abよりも高い(倍以上の）rpsを叩き出せ、cpuもいい感じに使い切れる。


## Install
```
wget https://github.com/wg/wrk/archive/4.0.2.tar.gz && \
tar xf 4.0.2.tar.gz && \
cd wrk-4.0.2 && \
make && \
sudo mv wrk /usr/local/bin/
```

## Run wrk
```
./wrk -c 1 -t 1 --latency -d 10 http://127.0.0.1/

./wrk -h
./wrk: invalid option -- 'h'
Usage: wrk <options> <url>
  Options:
    -c, --connections <N>  Connections to keep open
    -d, --duration    <T>  Duration of test
    -t, --threads     <N>  Number of threads to use

    -s, --script      <S>  Load Lua script file
    -H, --header      <H>  Add header to request
        --latency          Print latency statistics
        --timeout     <T>  Socket/request timeout
    -v, --version          Print version details

  Numeric arguments may include a SI unit (1k, 1M, 1G)
  Time arguments may include a time unit (2s, 2m, 2h)
```


## Run wrk
```
./wrk -c 1 -t 1 --latency -d 10 http://127.0.0.1:1323
Running 10s test @ http://127.0.0.1:1323
  1 threads and 1 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    23.54us   43.66us   3.05ms   97.79%
    Req/Sec    49.94k     4.58k   51.66k    96.00%
  Latency Distribution
     50%   18.00us
     75%   21.00us
     90%   25.00us
     99%  184.00us
  497098 requests in 10.00s, 61.63MB read
Requests/sec:  49700.22
Transfer/sec:      6.16MB
```

## 測定時の注意事項
* -c, -t はある程度上げるとよい(上げすぎてもだめ)
* ベンチマークの際にmpstatで、CPUを使い切ってるか確認するとよい
    * 基本的にはCPU性能でサチることが多い
    * $ mpstat -P ALL 1
* 99% Latencyが大きなったらパフォーマンスが劣化してる(サーバ側 or クライアント側でCPUがサチるなど原因があるはず)

```
# 1スレッドでwrkを実行
./wrk -c 1 -t 1 --latency -d 10 http://127.0.0.1:1323
Running 10s test @ http://127.0.0.1:1323
  1 threads and 1 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    23.54us   43.66us   3.05ms   97.79%
    Req/Sec    49.94k     4.58k   51.66k    96.00%
  Latency Distribution
     50%   18.00us
     75%   21.00us
     90%   25.00us
     99%  184.00us
  497098 requests in 10.00s, 61.63MB read
Requests/sec:  49700.22
Transfer/sec:      6.16MB


# 2スレッドでwrkを実行
# 2CPUなのでここでCPUがサチる
# 99%のLatencyが大きめに出てるが、この辺が妥当
$ ./wrk -c 2 -t 2 --latency -d 10 http://127.0.0.1:1323
Running 10s test @ http://127.0.0.1:1323
  2 threads and 2 connections

  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    69.34us  322.05us   7.59ms   97.53%
    Req/Sec    41.03k     4.29k   44.90k    92.50%
  Latency Distribution
     50%   21.00us
     75%   23.00us
     90%   28.00us
     99%    1.85ms
  816289 requests in 10.00s, 101.20MB read
Requests/sec:  81620.81
Transfer/sec:     10.12MB


# 4スレッドでwrkを実行
# 2CPUなのでここでCPUがサチり、Latencyも明らかに劣化している
# Request/secは、2スレッド時よりも出て入るが、Latencyも跳ねているのでSLA的にアウト
$ ./wrk -c 4 -t 4 --latency -d 10 http://127.0.0.1:1323
Running 10s test @ http://127.0.0.1:1323
  4 threads and 4 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     2.32ms    5.82ms  58.35ms   88.41%
    Req/Sec    21.73k     9.27k   49.12k    69.83%
  Latency Distribution
     50%   29.00us
     75%   94.00us
     90%    9.67ms
     99%   28.25ms
  867198 requests in 10.10s, 107.51MB read
Requests/sec:  85894.12
Transfer/sec:     10.65MB
```

* このサーバの最大性能としては以下が妥当
    * 実際のRPSとしてはlocalhostからのデータではなく、別サーバからの測定データを利用する

```
$ ./wrk -c 2 -t 2 --latency -d 10 http://127.0.0.1:1323
Running 10s test @ http://127.0.0.1:1323
  2 threads and 2 connections

  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    69.34us  322.05us   7.59ms   97.53%
    Req/Sec    41.03k     4.29k   44.90k    92.50%
  Latency Distribution
     50%   21.00us
     75%   23.00us
     90%   28.00us
     99%    1.85ms
  816289 requests in 10.00s, 101.20MB read
Requests/sec:  81620.81
Transfer/sec:     10.12MB
```
