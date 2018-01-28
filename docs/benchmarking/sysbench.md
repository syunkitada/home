# sysbench
* file I/O performance
* scheduler performance
* memory allocation and transfer speed
* POSIX threads implementation performance
* database server performance



## CentOS7でのインストール実行方法
```
# インストール
$ sudo yum install epel-release
$ sudo yum install sysbench

# 実行
$ sysbench --test=cpu run --num-threads=1
```


## 実行オプション
* sysbench [options]... [testname] [command]
    * --threads=N                     number of threads to use [1]
    * --events=N                      limit for total number of events [0]
    * --time=N                        limit for total execution time in seconds [10]
    * --forced-shutdown=STRING        number of seconds to wait after the --time limit before forcing shutdown, or 'off' to disable [off]
    * --thread-stack-size=SIZE        size of stack per thread [64K]
    * --rate=N                        average transactions rate. 0 for unlimited rate [0]
    * --debug[=on|off]                print more debugging info [off]


## cpu
* cpuパフォーマンスのベンチマーク
* 素数探索を上限値(cpu-max-pime)まで行う
* 実行オプション
    * --cpu-max-prime=N upper limit for primes generator [10000]
```
$ sysbench --num-threads={1,2,4,...,max_cpu_core} cpu run --cpu-max-prime=100000
CPU speed:
    events per second:    50.10

General statistics:
    total time:                          10.0186s
    total number of events:              502

Latency (ms):
         min:                                 19.55
         avg:                                 19.96
         max:                                 39.56
         95th percentile:                     20.00
         sum:                              10017.89

Threads fairness:
    events (avg/stddev):           502.0000/0.00
    execution time (avg/stddev):   10.0179/0.00
```

## threads
* スケジューラパフォーマンスのベンチマーク
* sysbenchは、特定数のスレッド(thread-yields)と特定数のmutex(thread-locks)を作成する
* 各スレッドはmutexをlockするような要求を実行し、CPUを生成し(yields)、スケジューラによってrunキューに戻るとmutexのロック解除する(unlock)
* 実行オプション
    * --thread-yields=N number of yields to do per request [1000]
    * --thread-locks=N  number of locks per thread [8]


## mutex
* mutex実装のパフォーマンスのベンチマーク
* すべてのスレッドが同時に実行される状況をエミュレートし、短時間で、(グローバル変数をインクリメントして)mutex lockを取得する
* 実行オプション
    * --mutex-num=N   total size of mutex array [4096]
    * --mutex-locks=N number of mutex locks to do per thread [50000]
    * --mutex-loops=N number of empty loops to do outside mutex lock [10000]


## memory
* メモリのベンチマーク
    * シーケンシャル、ランダムでread、writeを行う
* オプションに応じて、各スレッドはすべてのメモリ操作に対してブローバルブロック、またはローカルブロックのいずれかにアクセスできる
* 実行オプション
    * --memory-block-size=SIZE    size of memory block for test [1K]
    * --memory-total-size=SIZE    total size of data to transfer [100G]
    * --memory-scope=STRING       memory access scope {global,local} [global]
    * --memory-hugetlb[=on|off]   allocate memory from HugeTLB pool [off]
    * --memory-oper=STRING        type of memory operations {read, write, none} [write]
    * --memory-access-mode=STRING memory access mode {seq,rnd} [seq]


## fileio
* さまざまな種類のファイルI/Oワークロードでベンチマーク
* 準備段階で、指定されたサイズの指定された数のファイルを生成し、実行段階で各スレッドがこのファイルセットに対して指定されたI/O操作を実行する
* --validationオプションを使用すると、sysbenchはディスクから読み取られたすべてのデータに対してチェックサム検証を行う
    * 書き込み操作では、ブロックにランダムな値が入力されると、チェックサムが計算され、ファイル内のこのブロックのオフセットとともにブロックに格納される
    * 読み取り操作では、格納されているオフセットと実際のオフセットを比較し、格納されたチェックサムと実際に計算されたチェックサムを比較することによってブロックが検証される
* I/Oのテストモード
    * seqwr: sequential write
    * seqrewr: sequential rewrite
    * seqrd: sequential read
    * rndrd: random read
    * rndwr: random write
    * rndrw: combined random read/write
* I/Oのアクセスモード
    * sync
    * async
    * mmap
* file-extra-flags
    * sync
    * dsync
    * direct
* 実行オプション
  --file-num=N              number of files to create [128]
  --file-block-size=N       block size to use in all IO operations [16384]
  --file-total-size=SIZE    total size of files to create [2G]
  --file-test-mode=STRING   test mode {seqwr, seqrewr, seqrd, rndrd, rndwr, rndrw}
  --file-io-mode=STRING     file operations mode {sync,async,mmap} [sync]
  --file-async-backlog=N    number of asynchronous operatons to queue per thread [128]
  --file-extra-flags=STRING additional flags to use on opening files {sync,dsync,direct} []
  --file-fsync-freq=N       do fsync() after this number of requests (0 - don't use fsync()) [100]
  --file-fsync-all[=on|off] do fsync() after each write operation [off]
  --file-fsync-end[=on|off] do fsync() at the end of test [on]
  --file-fsync-mode=STRING  which method to use for synchronization {fsync, fdatasync} [fsync]
  --file-merged-requests=N  merge at most this number of IO requests if possible (0 - don't merge) [0]
  --file-rw-ratio=N         reads/writes ratio for combined test [1.5]

```
$ sysbench --num-threads=16 --test=fileio --file-total-size=3G --file-test-mode=rndrw prepare
$ sysbench --num-threads=16 --test=fileio --file-total-size=3G --file-test-mode=rndrw run
$ sysbench --num-threads=16 --test=fileio --file-total-size=3G --file-test-mode=rndrw cleanup
```


## oltp
* データベースパフォーマンスのベンチマーク
* prepareステージで、以下のデータベースを作成する
```
 CREATE TABLE `sbtest` (
 `id` int(10) unsigned NOT NULL auto_increment,
 `k` int(10) unsigned NOT NULL default '0',
 `c` char(120) NOT NULL default '',
 `pad` char(60) NOT NULL default '',
 PRIMARY KEY (`id`),
 KEY `k` (`k`));
```

sysbench --db-driver=mysql --mysql-user=root --mysql-password=<pwd> \
  --mysql-socket=<mysql.sock path> --mysql-db=foo --range_size=100 \
  --table_size=10000 --tables=2 --threads=1 --events=0 --time=60 \
  --rand-type=uniform /usr/share/sysbench/oltp_read_only.lua run

oltp_delete.lua            oltp_point_select.lua      oltp_read_write.lua        oltp_update_non_index.lua
oltp_insert.lua            oltp_read_only.lua         oltp_update_index.lua      oltp_write_only.lua


## 参考
* http://imysql.com/wp-content/uploads/2014/10/sysbench-manual.pdf
