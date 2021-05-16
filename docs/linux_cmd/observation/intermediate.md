# Observability tools intermediate

## strace

- システムコールをトレースする

```
$ sudo strace -tttT -p 12010
Process 12010 attached
1490533750.045816 accept4(4, {sa_family=AF_INET6, sin6_port=htons(37074), inet_pton(AF_INET6, "::1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, [28], SOCK_CLOEXEC) = 9 <5.685130>
1490533755.731239 getsockname(9, {sa_family=AF_INET6, sin6_port=htons(80), inet_pton(AF_INET6, "::1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, [28]) = 0 <0.000075>
1490533755.731445 fcntl(9, F_GETFL)     = 0x2 (flags O_RDWR) <0.000059>
1490533755.731619 fcntl(9, F_SETFL, O_RDWR|O_NONBLOCK) = 0 <0.000098>
1490533755.731898 read(9, "GET / HTTP/1.1\r\nUser-Agent: curl"..., 8000) = 73 <0.000061>
1490533755.732162 stat("/var/www/html/", {st_mode=S_IFDIR|0755, st_size=23, ...}) = 0 <0.000068>
1490533755.732467 stat("/var/www/html/index.html", {st_mode=S_IFREG|0644, st_size=12, ...}) = 0 <0.000059>
1490533755.732663 open("/var/www/html/index.html", O_RDONLY|O_CLOEXEC) = 10 <0.000084>
1490533755.732874 read(9, 0x7fa371536278, 8000) = -1 EAGAIN (Resource temporarily unavailable) <0.000053>
1490533755.733033 mmap(NULL, 12, PROT_READ, MAP_SHARED, 10, 0) = 0x7fa36f7a4000 <0.000052>
1490533755.733168 writev(9, [{"HTTP/1.1 200 OK\r\nDate: Sun, 26 M"..., 240}, {"hello world\n", 12}], 2) = 252 <0.001855>
1490533755.735228 munmap(0x7fa36f7a4000, 12) = 0 <0.000064>
1490533755.735395 write(7, "::1 - - [26/Mar/2017:13:09:15 +0"..., 79) = 79 <0.000075>
1490533755.735559 times({tms_utime=0, tms_stime=0, tms_cutime=0, tms_cstime=0}) = 431041330 <0.000058>
1490533755.735809 close(10)             = 0 <0.000056>
1490533755.735956 poll([{fd=9, events=POLLIN}], 1, 5000) = 1 ([{fd=9, revents=POLLIN}]) <0.000051>
1490533755.736094 read(9, "", 8000)     = 0 <0.000048>
1490533755.736223 shutdown(9, SHUT_WR)  = 0 <0.000118>
1490533755.736412 poll([{fd=9, events=POLLIN}], 1, 2000) = 1 ([{fd=9, revents=POLLIN|POLLHUP}]) <0.000049>
1490533755.736557 read(9, "", 512)      = 0 <0.000045>
1490533755.736664 close(9)              = 0 <0.000155>
1490533755.736885 read(5, 0x7ffc8fdf43ff, 1) = -1 EAGAIN (Resource temporarily unavailable) <0.000040>
1490533755.736998 accept4(4,


# ファイルに出力する
$ sudo strace -tttT -p 12010 -o test.log

# 統計情報を表示する
$ sudo strace -p 21479 -c
strace: Process 21479 attached
^Cstrace: Process 21479 detached
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
  0.00    0.000000           0         8           futex
  0.00    0.000000           0         1           epoll_wait
------ ----------- ----------- --------- --------- ----------------
100.00    0.000000                     9           total
```

プロセスが呼び出すシステムコールをトレースする。
このときシステムコールがエラーになる箇所を探すと、不具合の手掛かりになる。

## ltrace

- 共有ライブラリの関数呼び出しをトレースする
- 仕組み
  - 環境変数 PATH をたどって実行バイナリの絶対パスを調べる
  - バイナリと依存しているすべての共有ライブラリを elfutils を用いて読み込み、関数のシンボル名とその PLT 内のアドレスのリストを取得する
  - fork して子プロセス内で ptrace(PTRACE_TRACEME, ...) をセットし、それからバイナリを実行する
    - ptrace は、実行中のプロセスに対して、レジスタの書き換えやメモリ上のデータの書き換えといった操作ができるシステムコール
  - wait() で待っている親プロセスに SIGTRAP が伝わる
  - 親プロセスでは先ほど作っておいたリストを元に、各関数の PLT の該当アドレスにブレークポイント命令 (i386 では 0xcc) を書き込む 。このとき、書き換える前の値を保存しておく
  - これにより子プロセスが共有ライブラリの関数を呼び出すたびに SIGTRAP が発生するので、親プロセスはループ内で wait で SIGTRAP を待って適宜ブレークポイントしつつ、子プロセスが終了するまでループを回す
  - PLT (Procedure Linkage Table) には ELF の共有ライブラリの関数を呼び出すときに必ず経由するコードが各関数ごとに用意されています。
    - ltrace はこの PLT にブレークポイントを書き込むことによって、共有ライブラリの関数呼び出しをフックしています。

```bash
# コマンドをトレースする
$ sudo ltrace wget http://127.0.0.1/

# ファイルに出力する
$ sudo ltrace -o log.txt wget http://127.0.0.1/
```

## lsof

ファイルディスクリプタを使っているプロセスを調べる

```
$ sudo lsof -i:80
COMMAND   PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
httpd   12009   root    4u  IPv6  31227      0t0  TCP *:http (LISTEN)
httpd   12010 apache    4u  IPv6  31227      0t0  TCP *:http (LISTEN)
httpd   12011 apache    4u  IPv6  31227      0t0  TCP *:http (LISTEN)
httpd   12012 apache    4u  IPv6  31227      0t0  TCP *:http (LISTEN)
httpd   12013 apache    4u  IPv6  31227      0t0  TCP *:http (LISTEN)
httpd   12014 apache    4u  IPv6  31227      0t0  TCP *:http (LISTEN)

```

## sar

System Activity Reporter

```bash
$ sar -n TCP,ETCP,DEV 1
```

## iotop

```bash
$ sudo iotop
Total DISK READ :       0.00 B/s | Total DISK WRITE :       0.00 B/s
Actual DISK READ:       0.00 B/s | Actual DISK WRITE:       0.00 B/s
  TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND
24094 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.03 % [kworker/0:2]
23552 be/4 apache      0.00 B/s    0.00 B/s  0.00 %  0.00 % httpd -DFOREGROUND
    1 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % systemd --system --deserialize 41
    2 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [kthreadd]
    3 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [ksoftirqd/0]
```

## slabtop

- スラブアロケータのメモリ利用量
- https://www.ibm.com/developerworks/jp/linux/library/l-linux-slab-allocator/

```bash
$ slabtop
Active / Total Objects (% used)    : 772062 / 781600 (98.8%)
 Active / Total Slabs (% used)      : 15524 / 15524 (100.0%)
 Active / Total Caches (% used)     : 65 / 97 (67.0%)
 Active / Total Size (% used)       : 83137.34K / 84572.69K (98.3%)
 Minimum / Average / Maximum Object : 0.01K / 0.11K / 15.88K

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
128860 127969  99%    0.02K    758      170      3032K fsnotify_event_holder
125440 124298  99%    0.03K    980      128      3920K kmalloc-32
 98304  97251  98%    0.01K    192      512       768K kmalloc-8
 86751  86751 100%    0.19K   4131       21     16524K dentry
 75387  75387 100%    0.10K   1933       39      7732K buffer_head
 73984  72910  98%    0.06K   1156       64      4624K kmalloc-64
 57856  56381  97%    0.02K    226      256       904K kmalloc-16
 31977  31977 100%    0.08K    627       51      2508K selinux_inode_security
 16980  16980 100%    1.06K   1132       15     18112K xfs_inode
 13962  13962 100%    0.15K    537       26      2148K xfs_ili
 12077  11813  97%    0.58K    929       13      7432K inode_cache
 11700  11700 100%    0.11K    325       36      1300K sysfs_dir_cache
  8892   8650  97%    0.21K    494       18      1976K vm_area_struct
  7462   7462 100%    0.57K    533       14      4264K radix_tree_node
```

## pcstat

- https://github.com/tobert/pcstat
- ページキャッシュ統計を表示する
- データベースなどのパフォーマンス分析で使える

```bash
curl -L -o pcstat https://github.com/tobert/pcstat/raw/2014-05-02-01/pcstat.x86_64
chmod 755 pcstat
$ ~/pcstat data*
|-----------+----------------+------------+-----------+---------|
| Name      | Size           | Pages      | Cached    | Percent |
|-----------+----------------+------------+-----------+---------|
| data00    | 6682           | 2          | 2         | 100.000 |
| data01    | 12127          | 3          | 3         | 100.000 |
| data02    | 11876          | 3          | 3         | 100.000 |
|-----------+----------------+------------+-----------+---------|
```

## tiptop

- VM では利用できない（PMCs が enabled である必要がある)
- Mcycle: CPU cycles
- Minst: Instructions
- IPC(Instructions Per Clock cycle): Executed instructions per cycle
- %MISS: Cache miss per instructions (in %)
- %BMIS: Branch misprediction per instruction (in %)

```
$ tiptop
tiptop -                                                        [root]
Tasks: 241 total,   2 displayed                                                                     screen  0: default

  PID [ %CPU] %SYS    P   Mcycle   Minstr   IPC  %MISS  %BMIS  %BUS COMMAND
 3092+   0.5   0.0    0     1.84     1.35  0.73   0.97   0.95   0.1 beam.smp
 2386+   0.5   0.0    0     0.24     0.09  0.38   8.95   1.11   0.3 mysqld
```

## atop

- top ライクなツールだが、top よりも細かいシステム情報がわかる
- cpu の irq や memory, disk, network の利用量まで見れる

```
$ atop
ATOP - benchmark-1-hostname                                                        2017/03/27  03:32:38                                                        -----------                                                        10s elapsed
PRC | sys    0.01s |  user   0.01s |              |               | #proc     82 |  #trun      2 |              | #tslpi    98  | #tslpu     0 |               | #zombie    0 | clones     0  |              |               | no  procacct |
CPU | sys       0% |  user      0% |              |  irq       0% |              |  idle    100% |              | wait      0%  |              |               | steal     0% | guest     0%  | curf 3.20GHz |               | curscal   ?% |
CPL | avg1    0.00 |               | avg5    0.02 |               | avg15   0.05 |               |              | csw      139  |              | intr      96  |              |               |              | numcpu     1  |              |
MEM | tot     3.5G |  free    2.9G | cache 478.9M |  dirty   0.0M | buff    0.9M |  slab   87.3M | slrec  60.1M | shmem  16.4M  | shrss   0.0M | shswp   0.0M  |              | vmbal   0.0M  |              | hptot   0.0M  | hpuse   0.0M |
SWP | tot     0.0M |  free    0.0M |              |               |              |               |              |               |              |               |              |               | vmcom 244.9M | vmlim   1.8G  |              |
NET | transport    |  tcpi       1 | tcpo       1 |               | udpi       0 |  udpo       0 | tcpao      0 | tcppo      0  |              | tcprs      0  | tcpie      0 | tcpor      0  | udpnp      0 |               | udpie      0 |
NET | network      |  ipi        1 |              |  ipo        1 | ipfrw      0 |               | deliv      1 |               |              |               |              |               | icmpi      0 | icmpo      0  |              |
NET | eth0    ---- |  pcki       6 |              |  pcko       1 | si    0 Kbps |  so    1 Kbps |              | coll       0  | mlti       0 |               | erri       0 | erro       0  | drpi       5 |               | drpo       0 |

  PID              TID            SYSCPU            USRCPU             VGROW              RGROW            RUID                EUID                 THR             ST            EXC            S             CPU            CMD         1/1
  817                -             0.00s             0.01s                0K                 0K            root                root                   5             --              -            S              0%            tuned
22222                -             0.01s             0.00s                0K                 4K            fabric              fabric                 1             --              -            R              0%            atop
    1                -             0.00s             0.00s                0K                 0K            root                root                   1             --              -            S              0%            systemd
```

## dstat

- dstat は python で書かれており、python でプラグインも組み込むことができる

```
# 表示オプション
# -t: タイムスタンプ
# -a: よく使う基本オプション詰め合わせ(cdngy)
# -c: CPU使用率を表示する
# -d: DiskIOを表示する
# -g: ページIN/OUTを表示する(sと一緒に使用する）
# -s: swapのused/freeを表示する
# -m: メモリ使用量を表示する
# -i: 割り込みを表示
# -p: run, blk, new のプロセス数を表示する
# -y: 割り込み回数とコンテキストスイッチの回数を表示する

# フィルタリングオプション
# -C: 特定のコアだけ見る(e.g. -C 0,1,total)
# -D: 特定のディスクデバイスだけ見る(e.g. -D sda)
# -N: 特定のネットワークインターフェイスだけ見る(e.g. -N eth0)
# -I: 特定の割り込みだけ見る(e.g. -I 25)

# その他オプション
# --output dstat.csv: csvでファイルに書き込む

$ sudo dstat -tai

# -f: 各CPU、インターフェースごとにすべて表示
$ sudo dstat -taf

# cpuを使ってるプロセスを見る
$ sudo dstat -ta --top-cpu
# プロセスのpid, read, writeも表示する
$ sudo dstat -ta --top-cpu-adv

# ioを使ってるプロセスを見る
$ sudo dstat -ta --top-io --top-bio
# プロセスのpid, cpu使用率も表示する
$ sudo dstat -ta --top-io-adv --top-bio-adv

# vmstat like
$ sudo dstat -tv

# システム情報や、プラグイン情報を表示
$ dstat -V
Dstat 0.7.2
Written by Dag Wieers <dag@wieers.com>
Homepage at http://dag.wieers.com/home-made/dstat/

Platform posix/linux2
Kernel 3.10.0-327.el7.x86_64
Python 2.7.5 (default, Nov 20 2015, 02:00:19)
[GCC 4.8.5 20150623 (Red Hat 4.8.5-4)]

Terminal type: xterm-256color (color support)
Terminal size: 32 lines, 237 columns

Processors: 1
Pagesize: 4096
Clock ticks per secs: 100

internal:
        aio, cpu, cpu24, disk, disk24, disk24old, epoch, fs, int, int24, io, ipc, load, lock, mem, net, page, page24, proc, raw, socket, swap, swapold, sys, tcp, time, udp, unix, vm
/usr/share/dstat:
        battery, battery-remain, cpufreq, dbus, disk-tps, disk-util, dstat, dstat-cpu, dstat-ctxt, dstat-mem, fan, freespace, gpfs, gpfs-ops, helloworld, innodb-buffer, innodb-io, innodb-ops, lustre, memcache-hits, mysql-io,
        mysql-keys, mysql5-cmds, mysql5-conn, mysql5-io, mysql5-keys, net-packets, nfs3, nfs3-ops, nfsd3, nfsd3-ops, ntp, postfix, power, proc-count, qmail, rpc, rpcd, sendmail, snooze, squid, test, thermal, top-bio, top-bio-adv,
        top-childwait, top-cpu, top-cpu-adv, top-cputime, top-cputime-avg, top-int, top-io, top-io-adv, top-latency, top-latency-avg, top-mem, top-oom, utmp, vm-memctl, vmk-hba, vmk-int, vmk-nic, vz-cpu, vz-io, vz-ubc, wifi
```

## blktrace

- blktrace はブロック I/O レイヤの入口と出口, そして内部での I/O リクエストの状態をトレースすることができる
- I/O リクエストは以下のようなパスを通りデバイスへたどり着きます
  - アプリケーション -> [ファイルシステム -> ページキャッシュ -> ブロック I/O レイヤ -> デバイスドライバ] -> デバイス
- I/O スケジューラにより I/O リクエストの並び換えや連接ブロックへの I/O リクエストのマージ等が行われているため、ブロック I/O レイヤの入口と出口では I/O リクエストの順番が異なります

```bash
# デバイスをトレースする
$ sudo blktrace -d /dev/sda -o test

# トレースした結果を見る
$ blkparse -i test.blktrace.0
```

## /proc

Many raw kernel counters

```bash

```

## numastat

- 参考: [numastat](https://access.redhat.com/documentation/ja-JP/Red_Hat_Enterprise_Linux/7/html/Performance_Tuning_Guide/sect-Red_Hat_Enterprise_Linux-Performance_Tuning_Guide-Tool_Reference-numastat.html)
- NUMA ノードベースでオペレーティングシステムとプロセッサーのメモリー統計情報 (割り当てヒットとミスなど) を表示する
- numactl で管理者は指定したスケジュールまたはメモリー配置ポリシーでプロセスを実行することができる。
- numactl は共有メモリーセグメントやファイルに永続的なポリシーを設定したり、プロセスのプロセッサー親和性やメモリー親和性を設定することもできる。

## CPU の周波数を確認

```
$ cat /proc/cpuinfo | egrep "processor|cpu MHz"
processor       : 0
cpu MHz         : 1375.675
processor       : 1
cpu MHz         : 1379.284
processor       : 2
cpu MHz         : 1443.587
processor       : 3
cpu MHz         : 1454.012
processor       : 4
cpu MHz         : 1545.231
processor       : 5
cpu MHz         : 1438.988
processor       : 6
cpu MHz         : 1546.319
processor       : 7
cpu MHz         : 1450.727
processor       : 8
cpu MHz         : 1544.963
processor       : 9
cpu MHz         : 1523.568
processor       : 10
cpu MHz         : 1545.989
processor       : 11
cpu MHz         : 1546.597
```

## SystemTap

- SystemTap は、実行している Linux カーネルで簡易情報を取得できるようにするツール
- パフォーマンスまたは機能（バグ）の問題に関する情報を取得するために使用する
