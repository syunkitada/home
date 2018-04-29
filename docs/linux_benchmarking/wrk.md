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
./wrk -c 2 -t 2 -d 10 http://127.0.0.1/

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
./wrk -c 2 -t 2 -d 10 http://127.0.0.1/
Running 10s test @ http://127.0.0.1/
  2 threads and 2 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    32.42us   57.97us   4.30ms   99.71%
    Req/Sec    31.99k     2.64k   43.81k    96.52%
  639972 requests in 10.10s, 7.01GB read
Requests/sec:  63368.94
Transfer/sec:    710.69MB
```

## rpsを最大化するためのoption最適化
* -c, -t はある程度上げるとよい
* ベンチマークの際にmpstatを投げておいて、CPUを使い切ってるか確認するとよい

```
./wrk -c 1 -t 1 -d 10 http://127.0.0.1/
Running 10s test @ http://127.0.0.1/
  1 threads and 1 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    25.11us   83.12us   5.13ms   99.83%
    Req/Sec    42.99k     3.33k   44.38k    97.03%
  431855 requests in 10.10s, 4.73GB read
Requests/sec:  42762.71
Transfer/sec:    479.59MB

./wrk -c 2 -t 2 -d 10 http://127.0.0.1/
Running 10s test @ http://127.0.0.1/
  2 threads and 2 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    32.51us   53.70us   3.99ms   99.53%
    Req/Sec    31.71k     2.88k   33.63k    96.04%
  637048 requests in 10.10s, 6.98GB read
Requests/sec:  63077.58
Transfer/sec:    707.43MB

./wrk -c 4 -t 4 -d 10 http://127.0.0.1/
Running 10s test @ http://127.0.0.1/
  4 threads and 4 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   473.04us  782.80us  11.95ms   82.08%
    Req/Sec    19.57k    11.27k   42.99k    65.59%
  780995 requests in 10.10s, 8.55GB read
Requests/sec:  77331.61
Transfer/sec:    867.29MB

./wrk -c 8 -t 8 -d 10 http://127.0.0.1/
Running 10s test @ http://127.0.0.1/
  8 threads and 8 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.00ms    1.78ms  34.23ms   85.54%
    Req/Sec    10.00k     1.84k   37.17k    82.71%
  800270 requests in 10.10s, 8.76GB read
Requests/sec:  79236.80
Transfer/sec:      0.87GB

./wrk -c 16 -t 16 -d 10 http://127.0.0.1/
Running 10s test @ http://127.0.0.1/
  16 threads and 16 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     2.81ms    4.38ms  42.10ms   82.35%
    Req/Sec     5.12k     1.13k   30.70k    95.32%
  816928 requests in 10.10s, 8.95GB read
Requests/sec:  80888.72
Transfer/sec:      0.89GB

./wrk -c 32 -t 32 -d 10 http://127.0.0.1/
Running 10s test @ http://127.0.0.1/
  32 threads and 32 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     7.50ms   10.99ms  95.39ms   80.73%
    Req/Sec     2.53k   597.41     9.55k    92.72%
  808858 requests in 10.09s, 8.86GB read
Requests/sec:  80129.79
Transfer/sec:      0.88GB
```
