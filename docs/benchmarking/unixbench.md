# unixbench


## CentOS7
実行方法
```
$ yum -y install perl perl-Time-HiRes make gcc git
$ git clone https://github.com/kdlucas/byte-unixbench
$ cd byte-unixbench/UnixBench
$ ./Run
```


## 実行オプション
* -q  不要な出力を抑止します
* -v  実行コマンドなどの詳細情報を出力します
* -i <n>  <n>に繰り返し回数を指定します(指定が無い場合は、10回繰り返されます)
* -c <n>  <n>に計測時のCPUの数を指定します(指定が無い場合は、1コアの場合と、全てのコアの場合が実行されます)


## 16コア以上の測定でははパッチが必要
```
$ wget http://storage.googleapis.com/google-code-attachments/byte-unixbench/issue-4/comment-1/fix-limitation.patch
$ patch Run fix-limitation.patch
```


## 結果の見方
```
$ ./Run
[fabric@benchmark-1 UnixBench]$ ./Run
gcc -o pgms/arithoh -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME -Darithoh src/arith.c
gcc -o pgms/register -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME -Ddatum='register int' src/arith.c
gcc -o pgms/short -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME -Ddatum=short src/arith.c
gcc -o pgms/int -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME -Ddatum=int src/arith.c
gcc -o pgms/long -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME -Ddatum=long src/arith.c
gcc -o pgms/float -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME -Ddatum=float src/arith.c
gcc -o pgms/double -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME -Ddatum=double src/arith.c
gcc -o pgms/hanoi -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME src/hanoi.c
gcc -o pgms/syscall -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME src/syscall.c
gcc -o pgms/context1 -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME src/context1.c
gcc -o pgms/pipe -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME src/pipe.c
gcc -o pgms/spawn -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME src/spawn.c
gcc -o pgms/execl -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME src/execl.c
gcc -o pgms/dhry2 -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME -DHZ= ./src/dhry_1.c ./src/dhry_2.c
gcc -o pgms/dhry2reg -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME -DHZ= -DREG=register ./src/dhry_1.c ./src/dhry_2.c
gcc -o pgms/looper -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME src/looper.c
gcc -o pgms/fstime -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME src/fstime.c
gcc -o pgms/whetstone-double -Wall -pedantic -O3 -ffast-math -march=native -mtune=native -I ./src -DTIME -DDP -DGTODay -DUNIXBENCH src/whets.c -lm
make all
make[1]: Entering directory `/home/fabric/byte-unixbench/UnixBench'
make distr
make[2]: Entering directory `/home/fabric/byte-unixbench/UnixBench'
Checking distribution of files
./pgms  exists
./src  exists
./testdir  exists
./tmp  exists
./results  exists
make[2]: Leaving directory `/home/fabric/byte-unixbench/UnixBench'
make programs
make[2]: Entering directory `/home/fabric/byte-unixbench/UnixBench'
make[2]: Nothing to be done for `programs'.
make[2]: Leaving directory `/home/fabric/byte-unixbench/UnixBench'
make[1]: Leaving directory `/home/fabric/byte-unixbench/UnixBench'
sh: 3dinfo: command not found

   #    #  #    #  #  #    #          #####   ######  #    #   ####   #    #
   #    #  ##   #  #   #  #           #    #  #       ##   #  #    #  #    #
   #    #  # #  #  #    ##            #####   #####   # #  #  #       ######
   #    #  #  # #  #    ##            #    #  #       #  # #  #       #    #
   #    #  #   ##  #   #  #           #    #  #       #   ##  #    #  #    #
    ####   #    #  #  #    #          #####   ######  #    #   ####   #    #

   Version 5.1.3                      Based on the Byte Magazine Unix Benchmark

   Multi-CPU version                  Version 5 revisions by Ian Smith,
                                      Sunnyvale, CA, USA
   January 13, 2011                   johantheghost at yahoo period com

------------------------------------------------------------------------------
   Use directories for:
      * File I/O tests (named fs***) = /home/fabric/byte-unixbench/UnixBench/tmp
      * Results                      = /home/fabric/byte-unixbench/UnixBench/results
------------------------------------------------------------------------------


1 x Dhrystone 2 using register variables  1 2 3 4 5 6 7 8 9 10

1 x Double-Precision Whetstone  1 2 3 4 5 6 7 8 9 10

1 x Execl Throughput  1 2 3

1 x File Copy 1024 bufsize 2000 maxblocks  1 2 3

1 x File Copy 256 bufsize 500 maxblocks  1 2 3

1 x File Copy 4096 bufsize 8000 maxblocks  1 2 3

1 x Pipe Throughput  1 2 3 4 5 6 7 8 9 10

1 x Pipe-based Context Switching  1 2 3 4 5 6 7 8 9 10

1 x Process Creation  1 2 3

1 x System Call Overhead  1 2 3 4 5 6 7 8 9 10

1 x Shell Scripts (1 concurrent)  1 2 3

1 x Shell Scripts (8 concurrent)  1 2 3

2 x Dhrystone 2 using register variables  1 2 3 4 5 6 7 8 9 10

2 x Double-Precision Whetstone  1 2 3 4 5 6 7 8 9 10

2 x Execl Throughput  1 2 3

2 x File Copy 1024 bufsize 2000 maxblocks  1 2 3

2 x File Copy 256 bufsize 500 maxblocks  1 2 3

2 x File Copy 4096 bufsize 8000 maxblocks  1 2 3

2 x Pipe Throughput  1 2 3 4 5 6 7 8 9 10

2 x Pipe-based Context Switching  1 2 3 4 5 6 7 8 9 10

2 x Process Creation  1 2 3

2 x System Call Overhead  1 2 3 4 5 6 7 8 9 10

2 x Shell Scripts (1 concurrent)  1 2 3

2 x Shell Scripts (8 concurrent)  1 2 3

========================================================================
   BYTE UNIX Benchmarks (Version 5.1.3)

   System: benchmark-1.example.com: GNU/Linux
   OS: GNU/Linux -- 3.10.0-514.10.2.el7.x86_64 -- #1 SMP Fri Mar 3 00:04:05 UTC 2017
   Machine: x86_64 (x86_64)
   Language: en_US.utf8 (charmap="UTF-8", collate="UTF-8")
   CPU 0: Intel Core i7 9xx (Nehalem Class Core i7) (6399.8 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext, SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   CPU 1: Intel Core i7 9xx (Nehalem Class Core i7) (6399.8 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext, SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   12:15:04 up 10 min,  1 user,  load average: 0.08, 0.05, 0.04; runlevel 2018-01-27

------------------------------------------------------------------------
Benchmark Run: 27 2018 12:15:04 - 12:44:41
2 CPUs in system; running 1 parallel copy of tests

Dhrystone 2 using register variables       52485119.8 lps   (10.0 s, 7 samples)
Double-Precision Whetstone                     3217.7 MWIPS (19.6 s, 7 samples)
Execl Throughput                               6145.8 lps   (30.0 s, 2 samples)
File Copy 1024 bufsize 2000 maxblocks       1462454.7 KBps  (30.0 s, 2 samples)
File Copy 256 bufsize 500 maxblocks          438128.6 KBps  (30.0 s, 2 samples)
File Copy 4096 bufsize 8000 maxblocks       3236341.0 KBps  (30.0 s, 2 samples)
Pipe Throughput                             2376139.6 lps   (10.0 s, 7 samples)
Pipe-based Context Switching                 536867.2 lps   (10.0 s, 7 samples)
Process Creation                              19975.5 lps   (30.0 s, 2 samples)
Shell Scripts (1 concurrent)                  10413.1 lpm   (60.0 s, 2 samples)
Shell Scripts (8 concurrent)                   1984.7 lpm   (60.0 s, 2 samples)
System Call Overhead                        3983241.1 lps   (10.0 s, 7 samples)

System Benchmarks Index Values               BASELINE       RESULT    INDEX
Dhrystone 2 using register variables         116700.0   52485119.8   4497.4
Double-Precision Whetstone                       55.0       3217.7    585.0
Execl Throughput                                 43.0       6145.8   1429.3
File Copy 1024 bufsize 2000 maxblocks          3960.0    1462454.7   3693.1
File Copy 256 bufsize 500 maxblocks            1655.0     438128.6   2647.3
File Copy 4096 bufsize 8000 maxblocks          5800.0    3236341.0   5579.9
Pipe Throughput                               12440.0    2376139.6   1910.1
Pipe-based Context Switching                   4000.0     536867.2   1342.2
Process Creation                                126.0      19975.5   1585.4
Shell Scripts (1 concurrent)                     42.4      10413.1   2455.9
Shell Scripts (8 concurrent)                      6.0       1984.7   3307.9
System Call Overhead                          15000.0    3983241.1   2655.5
                                                                   ========
System Benchmarks Index Score                                        2262.5

------------------------------------------------------------------------
Benchmark Run: 27 2018 12:44:41 - 13:14:17
2 CPUs in system; running 2 parallel copies of tests

Dhrystone 2 using register variables      102666882.6 lps   (10.0 s, 7 samples)
Double-Precision Whetstone                     6467.4 MWIPS (19.4 s, 7 samples)
Execl Throughput                              13332.0 lps   (30.0 s, 2 samples)
File Copy 1024 bufsize 2000 maxblocks       2200282.6 KBps  (30.0 s, 2 samples)
File Copy 256 bufsize 500 maxblocks          670620.0 KBps  (30.0 s, 2 samples)
File Copy 4096 bufsize 8000 maxblocks       5159536.4 KBps  (30.0 s, 2 samples)
Pipe Throughput                             4698253.8 lps   (10.0 s, 7 samples)
Pipe-based Context Switching                1049749.4 lps   (10.0 s, 7 samples)
Process Creation                              44415.0 lps   (30.0 s, 2 samples)
Shell Scripts (1 concurrent)                  15299.7 lpm   (60.0 s, 2 samples)
Shell Scripts (8 concurrent)                   2004.3 lpm   (60.0 s, 2 samples)
System Call Overhead                        6274239.3 lps   (10.0 s, 7 samples)

System Benchmarks Index Values               BASELINE       RESULT    INDEX
Dhrystone 2 using register variables         116700.0  102666882.6   8797.5
Double-Precision Whetstone                       55.0       6467.4   1175.9
Execl Throughput                                 43.0      13332.0   3100.5
File Copy 1024 bufsize 2000 maxblocks          3960.0    2200282.6   5556.3
File Copy 256 bufsize 500 maxblocks            1655.0     670620.0   4052.1
File Copy 4096 bufsize 8000 maxblocks          5800.0    5159536.4   8895.8
Pipe Throughput                               12440.0    4698253.8   3776.7
Pipe-based Context Switching                   4000.0    1049749.4   2624.4
Process Creation                                126.0      44415.0   3525.0
Shell Scripts (1 concurrent)                     42.4      15299.7   3608.4
Shell Scripts (8 concurrent)                      6.0       2004.3   3340.6
System Call Overhead                          15000.0    6274239.3   4182.8
                                                                   ========
System Benchmarks Index Score                                        3870.9

```

| 項目 | 説明 |
| --- | ---|
| Dhrystone 2 using register variables(dhry2reg) | 整数演算処理の性能をベンチマークする(Dhystoneというベンチマークツールを利用している) |
| Double-Precision Whetstone(whetstone-double)   | 浮動小数演算処理の性能をベンチマークする(Whetstonというベンチマークツールを利用している) |
| Execl Throughput(execl)                        | システムコール処理性能をベンチマークする(execl()というプロセスイメージを書き換えるシステムコールを繰り返す) |
| File Copy 1024 bufsize 2000 maxblocks(fstime)  | ファイルのコピーをくる返すテストで、2MByteのファイルを1024Byteごとに処理する(元々はディスク処理性能を図るものだったが、メモリやCPUのキャッシュの増大により、ディスク処理性能ではなくOSとCPUの処理性能を見るものになっている) |
| File Copy 256 bufsize 500 maxblocks(fsbuffer)  | fstimeと同様のテスト内容で、500KByteのファイルを256Byteごとに処理する |
| File Copy 4096 bufsize 8000 maxblocks(fsdisk)  | fstimeと同様のテスト内容で、8MByteのファイルを4096Byteごとに処理する  |
| Pipe Throughput(pipe)                          | 512Byteのデータのパイプ処理を繰り返しスループットテストする(元々はメモリ処理を図るものだったが、CPUのキャッシュ増大により、メモリ処理性能ではなく、OSとCPUの処理性能を見るためのモノになっている |
| Pipe-based Context Switching(context1)         | OSとCPUの処理性能を見る(2つのプロセス間で更新される値をパイプで渡すことで、プロセスのコンテキストスイッチを実行させます) |
| Process Creation(spawn)                        | OSとCPUの処理を見る(プロセスのフォークを繰り返します) |
| Shell Scripts (1 concurrent)(shell1)           | CPUの処理性能を見る(sort、grepなどのテキスト処理を繰り返す) |
| Shell Scripts (8 concurrent)(shell8)           | shell1と同じ処理を、8並列に実施する |
| System Call Overhead(syscall)                  | OSとCPUの処理性能を見る、getpid()というシステムコールを繰り返し実行します |


結果の見方
* System Benchmarks Index Scoreは、前テストケースの総合点なので単純な比較する場合はこの数値を比較すればよい
* 各テストケースごとに比較する場合は、各テストケースのINDEXを数値を比較すればよい
