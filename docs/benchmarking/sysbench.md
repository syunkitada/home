# sysbench

## CentOS7
```
$ yum -y install perl perl-Time-HiRes make gcc git
$ git clone https://github.com/kdlucas/byte-unixbench
$ cd byte-unixbench/UnixBench
$ ./Run
```


# CPU
-cpu-max-prime=100000
素数探索アルゴリズムの上限値いくつまで設定するか

-num-threads={1,2,4,8,16,32}
スレッド数を指定したセット分行う





iperf
-length 128k
-parallel {1,2,4,8,16,32}
-time 30s
