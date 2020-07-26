# sar

## sar のデータ収集

```
# sar -o [file] [収集間隔]
$ sar -o /tmp/sar.data 1
Linux 5.3.0-59-generic (owner-desktop)  06/27/20        _x86_64_        (12 CPU)

18:04:36        CPU     %user     %nice   %system   %iowait    %steal     %idle
18:04:37        all      0.58      0.00      0.17      0.08      0.00     99.17
18:04:38        all      0.08      0.00      0.08      0.08      0.00     99.75
^C

Average:        all      0.33      0.00      0.13      0.08      0.00     99.46
```

## Processor の統計を表示

```
$ sar -P ALL -f /tmp/sar.data
18:04:37        CPU     %user     %nice   %system   %iowait    %steal     %idle
18:04:38        all      0.08      0.00      0.08      0.08      0.00     99.75
18:04:38          0      1.01      0.00      0.00      0.00      0.00     98.99
18:04:38          1      0.00      0.00      0.00      0.00      0.00    100.00
18:04:38          2      0.00      0.00      0.00      0.00      0.00    100.00
18:04:38          3      0.00      0.00      0.00      0.00      0.00    100.00
18:04:38          4      0.00      0.00      0.00      0.00      0.00    100.00
18:04:38          5      0.00      0.00      0.00      0.00      0.00    100.00
18:04:38          6      0.00      0.00      0.00      0.00      0.00    100.00
18:04:38          7      0.00      0.00      0.00      0.00      0.00     99.01
18:04:38          8      0.00      0.00      0.00      0.00      0.00    100.00
18:04:38          9      0.00      0.00      0.00      0.00      0.00    100.00
18:04:38         10      0.00      0.00      0.00      0.00      0.00    100.00
18:04:38         11      0.00      0.00      0.00      0.00      0.00    100.00

Average:        CPU     %user     %nice   %system   %iowait    %steal     %idle
Average:        all      1.34      0.00      1.09      0.06      0.00     97.52
Average:          0      1.54      0.00      1.48      0.07      0.00     96.91
Average:          1      1.03      0.00      1.16      0.02      0.00     97.79
Average:          2      1.41      0.00      1.16      0.08      0.00     97.35
Average:          3      0.98      0.00      1.01      0.02      0.00     97.99
Average:          4      1.42      0.00      1.11      0.08      0.00     97.39
Average:          5      1.10      0.00      1.08      0.02      0.00     97.80
Average:          6      1.86      0.00      1.19      0.09      0.00     96.86
Average:          7      1.06      0.00      0.93      0.03      0.00     97.99
Average:          8      1.69      0.00      1.06      0.09      0.00     97.16
Average:          9      1.26      0.00      0.94      0.04      0.00     97.77
Average:         10      1.64      0.00      1.09      0.10      0.00     97.16
Average:         11      1.03      0.00      0.87      0.03      0.00     98.06


$ sar -P 1 -f /tmp/sar.data
Linux 5.3.0-59-generic (owner-desktop)  06/27/20        _x86_64_        (12 CPU)

17:49:59        CPU     %user     %nice   %system   %iowait    %steal     %idle
17:50:00          1      0.00      0.00      0.00      0.00      0.00    100.00
17:50:01          1      0.00      0.00      3.96      0.00      0.00     96.04
17:50:02          1      0.00      0.00      1.01      0.00      0.00     98.99
17:50:03          1      0.00      0.00      0.00      0.00      0.00    100.00
17:50:04          1      0.99      0.00      0.99      0.00      0.00     98.02
18:02:54          1      1.04      0.00      1.18      0.02      0.00     97.76
18:02:55          1      1.00      0.00      1.00      0.00      0.00     98.00
18:02:56          1      0.00      0.00      0.99      0.00      0.00     99.01
18:02:57          1      0.00      0.00      0.00      0.00      0.00    100.00
18:04:12          1      1.14      0.00      1.10      0.04      0.00     97.72
18:04:13          1      0.99      0.00      0.99      0.00      0.00     98.02
18:04:14          1      0.00      0.00      0.00      0.00      0.00    100.00
18:04:36          1      0.49      0.00      1.12      0.00      0.00     98.39
18:04:37          1      0.00      0.00      1.00      0.00      0.00     99.00
18:04:38          1      0.00      0.00      0.00      0.00      0.00    100.00
Average:          1      1.03      0.00      1.16      0.02      0.00     97.79
```

```
# CPU utilization の統計表示
# 各CPUごとの統計は表示できない
$ sar -u ALL -f /tmp/sar.data
17:49:59        CPU      %usr     %nice      %sys   %iowait    %steal      %irq     %soft    %guest    %gnice     %idle
17:50:00        all      0.50      0.00      0.42      0.08      0.00      0.00      0.00      0.00      0.00     99.00
17:50:01        all      3.36      0.00      3.02      0.08      0.00      0.00      0.50      0.00      0.00     93.04
17:50:02        all      1.50      0.00      1.83      0.00      0.00      0.00      0.33      0.08      0.00     96.25
17:50:03        all      0.08      0.00      0.08      0.08      0.00      0.00      0.00      0.00      0.00     99.75
17:50:04        all      0.75      0.00      0.34      0.00      0.00      0.00      0.00      0.00      0.00     98.91
```

```
# run queue, load, blockedの表示
$ sar -q -f /tmp/sar.data
Linux 5.3.0-59-generic (owner-desktop)  06/27/20        _x86_64_        (12 CPU)

17:49:59      runq-sz  plist-sz   ldavg-1   ldavg-5  ldavg-15   blocked
17:50:00            0      1208      0.69      0.90      0.85         0
17:50:01            1      1211      0.69      0.90      0.85         0
17:50:02            0      1208      0.69      0.90      0.85         0
17:50:03            0      1207      0.69      0.90      0.85         0
```

```
# 新規プロセス、コンテキストスイッチ数の統計
$ sar -w -f /tmp/sar.data
Linux 5.3.0-59-generic (owner-desktop)  06/27/20        _x86_64_        (12 CPU)

17:49:59       proc/s   cswch/s
17:50:00         0.00   4185.00
17:50:01        80.00  14469.00
17:50:02        42.00   5804.00
17:50:03         0.00   2970.00
17:50:04         0.00   4581.00
18:02:54        22.54   5556.08
```

## Intterupt の統計を表示

```
$ sar -I SUM -f /tmp/sar.data
Linux 5.3.0-59-generic (owner-desktop)  06/27/20        _x86_64_        (12 CPU)

17:49:59         INTR    intr/s
18:04:36          sum   2835.24
18:04:37          sum   2142.57
18:04:38          sum   1267.00
Average:          sum   2786.64
```

## Ram の統計を表示

```
$ sar -r -f /tmp/sar.data
Linux 5.3.0-59-generic (owner-desktop)  06/27/20        _x86_64_        (12 CPU)

17:49:59    kbmemfree   kbavail kbmemused  %memused kbbuffers  kbcached  kbcommit   %commit  kbactive   kbinact   kbdirty
17:50:00      6272068  13265084  26611600     80.93   1569972   4888756  15236556     43.56   4948240   3887872      1292
17:50:01      6269248  13262356  26614420     80.94   1569992   4889024  15228380     43.53   4949268   3888120      1424
17:50:02      6268852  13262132  26614816     80.94   1569996   4888980  15226268     43.53   4948312   3888112      1508
17:50:03      6268852  13262132  26614816     80.94   1570004   4888972  15226268     43.53   4948312   3888112      1528
17:50:04      6268820  13262160  26614848     80.94   1570008   4889068  15226268     43.53   4948324   3888160       596
18:02:54      6250076  13278444  26633592     80.99   1575604   4917732  15216468     43.50   4939084   3916632       880
18:02:55      6251572  13280080  26632096     80.99   1575604   4917900  15215952     43.50   4937044   3916764       784
18:02:56      6251472  13279988  26632196     80.99   1575624   4917940  15215952     43.50   4936844   3916768       980
18:02:57      6251472  13280048  26632196     80.99   1575624   4917976  15215952     43.50   4936844   3916828      1188
18:04:12      6247672  13280116  26635996     81.00   1576124   4921188  15225500     43.53   4938660   3918024      1196
18:04:13      6248200  13280660  26635468     81.00   1576136   4921212  15225500     43.53   4939004   3918032      1236
18:04:14      6248160  13280728  26635508     81.00   1576140   4921340  15225500     43.53   4939724   3918124      1364
18:04:36      6248076  13281644  26635592     81.00   1576288   4922088  15224396     43.52   4939700   3918932       788
18:04:37      6247816  13281440  26635852     81.00   1576300   4922148  15224396     43.52   4939836   3918984       832
18:04:38      6247816  13281508  26635852     81.00   1576300   4922236  15224396     43.52   4939840   3919052       912
Average:      6256011  13274568  26627657     80.98   1573981   4909771  15223850     43.52   4941936   3907901      1101

$ sar -r ALL -f /tmp/sar.data
Linux 5.3.0-59-generic (owner-desktop)  06/27/20        _x86_64_        (12 CPU)

17:49:59    kbmemfree   kbavail kbmemused  %memused kbbuffers  kbcached  kbcommit   %commit  kbactive   kbinact   kbdirty  kbanonpg    kbslab  kbkstack   kbpgtbl  kbvmused
17:50:00      6272068  13265084  26611600     80.93   1569972   4888756  15236556     43.56   4948240   3887872      1292   2377444    786148     19568     41176     41236
17:50:01      6269248  13262356  26614420     80.94   1569992   4889024  15228380     43.53   4949268   3888120      1424   2378452    786112     19568     41576     41364
```

```
$ sar -B -f /tmp/sar.data
Linux 5.3.0-59-generic (owner-desktop)  06/27/20        _x86_64_        (12 CPU)

17:49:59     pgpgin/s pgpgout/s   fault/s  majflt/s  pgfree/s pgscank/s pgscand/s pgsteal/s    %vmeff
17:50:00         0.00    988.00      3.00      0.00     12.00      0.00      0.00      0.00      0.00
17:50:01         0.00   2080.00  24595.00      0.00  19305.00      0.00      0.00      0.00      0.00
17:50:02         0.00    776.00  13042.00      0.00  11286.00      0.00      0.00      0.00      0.00
17:50:03         0.00   3160.00      0.00      0.00      7.00      0.00      0.00      0.00      0.00
```

```
# Swapの統計
$ sar -S -f /tmp/sar.data
17:49:59    kbswpfree kbswpused  %swpused  kbswpcad   %swpcad
17:50:00      2097148         0      0.00         0      0.00
17:50:01      2097148         0      0.00         0      0.00
17:50:02      2097148         0      0.00         0      0.00
```

```
# Hugepageの使用量を表示
$ sar -H -f /tmp/sar.data
Linux 5.3.0-59-generic (owner-desktop)  06/27/20        _x86_64_        (12 CPU)

17:49:59    kbhugfree kbhugused  %hugused
17:50:00      9437184   7340032     43.75
17:50:01      9437184   7340032     43.75
17:50:02      9437184   7340032     43.75
```

## Device の統計を表示

```
# deviceのIO統計
$ sar -d -f /tmp/sar.data
18:04:37          DEV       tps     rkB/s     wkB/s   areq-sz    aqu-sz     await     svctm     %util
18:04:38       dev7-0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
18:04:38       dev7-1      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
```

```
# blockのIO統計
$ sar -b -f /tmp/sar.data
Linux 5.3.0-59-generic (owner-desktop)  06/27/20        _x86_64_        (12 CPU)

17:49:59          tps      rtps      wtps   bread/s   bwrtn/s
17:50:00        86.00      0.00     86.00      0.00   1976.00
17:50:01        71.00      0.00     71.00      0.00   4160.00
17:50:02        20.00      0.00     20.00      0.00   1552.00
```

```
# FileSystemの使用量
$ sar -F -f /tmp/sar.data
18:04:37     MBfsfree  MBfsused   %fsused  %ufsused     Ifree     Iused    %Iused FILESYSTEM
18:04:38       133273     73879     35.66     40.78  12187951   1353425      9.99 /dev/nvme0n1p1
18:04:38            0         0    100.00    100.00         0       230    100.00 /dev/loop0

Summary:       133273     73879     35.66     40.78  12187951   1353425      9.99 /dev/nvme0n1p1
Summary:            0         0    100.00    100.00         0       230    100.00 /dev/loop0
Summary:            0       162    100.00    100.00         0     27798    100.00 /dev/loop2
```

## Network の統計を表示

```
# -n { <keyword> [,...] | ALL }
#  DEV     Network interfaces
#  EDEV    Network interfaces (errors)
#  NFS     NFS client
#  NFSD    NFS server
#  SOCK    Sockets (v4)
#  IP      IP traffic      (v4)
#  EIP     IP traffic      (v4) (errors)
#  ICMP    ICMP traffic    (v4)
#  EICMP   ICMP traffic    (v4) (errors)
#  TCP     TCP traffic     (v4)
#  ETCP    TCP traffic     (v4) (errors)
#  UDP     UDP traffic     (v4)
#  SOCK6   Sockets (v6)
#  IP6     IP traffic      (v6)
#  EIP6    IP traffic      (v6) (errors)
#  ICMP6   ICMP traffic    (v6)
#  EICMP6  ICMP traffic    (v6) (errors)
#  UDP6    UDP traffic     (v6)
#  FC      Fibre channel HBAs
#  SOFT    Software-based network processing

# Deviceの統計
$ sar -n DEV -f /tmp/sar.data
18:04:12        IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s   %ifutil
18:04:13      enp31s0      2.00      3.00      0.12      0.37      0.00      0.00      0.00      0.00
18:04:13     com-1-ex      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
18:04:13     com-2-ex      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
18:04:13           lo     93.00     93.00    208.85    208.85      0.00      0.00      0.00      0.00
18:04:13     com-4-ex      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
18:04:13      docker0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
18:04:13     com-0-ex      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00

Average:        IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s   %ifutil
Average:      enp31s0      2.14      4.01      0.15      1.61      0.00      0.00      0.06      0.00
Average:     com-1-ex      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:     com-2-ex      0.01      0.01      0.00      0.00      0.00      0.00      0.00      0.00
Average:           lo    187.55    187.55     73.62     73.62      0.00      0.00      0.00      0.00
Average:     com-4-ex      0.01      0.01      0.00      0.00      0.00      0.00      0.00      0.00
Average:      docker0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:     com-0-ex      0.02      0.02      0.00      0.00      0.00      0.00      0.00      0.00

# DeviceのError統計
$ sar -n EDEV -f /tmp/sar.data
18:04:38      enp31s0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
18:04:38     com-1-ex      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
18:04:38     com-2-ex      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
18:04:38           lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
18:04:38     com-4-ex      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
18:04:38      docker0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
18:04:38     com-0-ex      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00

Average:        IFACE   rxerr/s   txerr/s    coll/s  rxdrop/s  txdrop/s  txcarr/s  rxfram/s  rxfifo/s  txfifo/s
Average:      enp31s0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:     com-1-ex      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:     com-2-ex      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:           lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:     com-4-ex      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:      docker0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:     com-0-ex      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00


# TCPの統計
$ sar -n TCP,ETCP -f /tmp/sar.data
Linux 5.3.0-59-generic (owner-desktop)  06/27/20        _x86_64_        (12 CPU)

17:49:59     active/s passive/s    iseg/s    oseg/s
18:04:12         0.40      0.40    191.28    191.70
18:04:13         0.00      0.00     95.00     96.00
18:04:14         1.00      1.00    155.00    178.00
18:04:36         0.45      0.45    193.76    194.83
18:04:37         0.00      0.00    251.49    250.50
18:04:38         0.00      0.00    107.00    107.00
Average:         0.41      0.41    189.54    191.48

17:49:59     atmptf/s  estres/s retrans/s isegerr/s   orsts/s
18:04:12         0.00      0.40      0.00      0.00      0.40
18:04:13         0.00      0.00      0.00      0.00      0.00
18:04:14         0.00      0.00      0.00      0.00      0.00
18:04:36         0.00      0.45      0.00      0.00      0.45
18:04:37         0.00      0.00      0.00      0.00      0.00
18:04:38         0.00      0.00      0.00      0.00      0.00
Average:         0.00      0.40      0.01      0.00      0.40


# SOCKの統計
$ sar -n SOCK -f /tmp/sar.data
Linux 5.3.0-59-generic (owner-desktop)  06/27/20        _x86_64_        (12 CPU)

17:49:59       totsck    tcpsck    udpsck    rawsck   ip-frag    tcp-tw
17:50:00         1101       274         4         0         0         0
17:50:01         1103       274         4         0         0         0
17:50:02         1101       274         4         0         0         0
17:50:03         1101       274         4         0         0         0
```

## Power Management の統計

```
# -m { <keyword> [,...] | ALL }
#                 Power management statistics
#                 Keywords are:
#                 CPU     CPU instantaneous clock frequency
#                 FAN     Fans speed
#                 FREQ    CPU average clock frequency
#                 IN      Voltage inputs
#                 TEMP    Devices temperature
#                 USB     USB devices plugged into the system
```

```
# CPUの周波数
$ sar -m CPU -f /tmp/sar.data
17:49:59        CPU       MHz
17:50:00        all   1509.11
17:50:01        all   1788.33
17:50:02        all   1882.69
17:50:03        all   1475.06
```

```
# FANの速度
$ sar -m FAN -f /tmp/sar.data
17:49:59          FAN       rpm      drpm DEVICE
17:50:00            1    603.00    603.00 nouveau-pci-2300
17:50:01            1    573.00    573.00 nouveau-pci-2300
17:50:02            1    554.00    554.00 nouveau-pci-2300
17:50:03            1    530.00    530.00 nouveau-pci-2300
```

```
# Deviceの温度
$ sar -m TEMP -f /tmp/sar.data
17:49:59         TEMP      degC     %temp DEVICE
17:50:00            1     35.75     51.07 k10temp-pci-00c3
17:50:00            2     35.75      0.00 k10temp-pci-00c3
17:50:00            3     44.00     46.32 nouveau-pci-2300
17:50:01            1     44.75     63.93 k10temp-pci-00c3
17:50:01            2     44.75      0.00 k10temp-pci-00c3
17:50:01            3     44.00     46.32 nouveau-pci-2300

Average:            1     38.46     54.94 k10temp-pci-00c3
Average:            2     38.46      0.00 k10temp-pci-00c3
Average:            3     44.00     46.32 nouveau-pci-2300
```

## sar の定期実行

- sa1 というワンショットのコマンドを cron によって実行する

```
# 設定ファイルを有効化しておく
$ sudo sed -i 's/ENABLED="false"/ENABLED="true"/g' /etc/default/sysstat
```

```
# sarのログファイルは以下に保存される
$ ls /var/log/sysstat
sa27
```

```
# devian用のsa1みると、上記の設定ファイルをenableにしない限り、devian-sa1を実行してもなにも起こらない
$ cat /usr/lib/sysstat/debian-sa1
#!/bin/sh
# vim:ts=2:et
# Debian sa1 helper which is run from cron.d job, not to needlessly
# fill logs (see Bug#499461).

set -e

# Global variables:
#
#  our configuration file
DEFAULT=/etc/default/sysstat
#  default setting, overriden in the above file
ENABLED=false

# Read defaults file
if [ -r "$DEFAULT" ]; then
  . "$DEFAULT"
fi

if [ "true" = "$ENABLED" ]; then
  exec /usr/lib/sysstat/sa1 "$@"
fi

exit 0
```

- sysstat をインストールすると cron によって定期的に debian-sa1 を実行するよう設定される

```
$ cat /etc/cron.d/sysstat
# The first element of the path is a directory where the debian-sa1
# script is located
PATH=/usr/lib/sysstat:/usr/sbin:/usr/sbin:/usr/bin:/sbin:/bin

# Activity reports every 10 minutes everyday
5-55/10 * * * * root command -v debian-sa1 > /dev/null && debian-sa1 1 1

# Additional run at 23:59 to rotate the statistics file
59 23 * * * root command -v debian-sa1 > /dev/null && debian-sa1 60 2
```

- 起動時に sysstat が実行されるように設定する
- これは、起動時の統計を集計するためのワンショット

```
$ sudo systemctl enable sysstat

# これをrestartすると、sysstatとしてはサーバがリスタートしたと記録するため、むやみに実行してはいけない
# $ sudo systemctl restart sysstat
```

```
$ sudo cat /lib/systemd/system/sysstat.service
# /lib/systemd/system/sysstat.service
# (C) 2012 Peter Schiffer (pschiffe <at> redhat.com)
# (C) 2017 Robert Luberda <robert@debian.org>
#
# sysstat systemd unit file:
#        Insert a dummy record in current daily data file.
#        This indicates that the counters have restarted from 0.

[Unit]
Description=Resets System Activity Data Collector
Documentation=man:sa1(8) man:sadc(8) man:sar(1)

[Service]
Type=oneshot
RemainAfterExit=yes
User=root
ExecStart=/usr/lib/sysstat/debian-sa1 --boot

[Install]
WantedBy=multi-user.target
```

## Json で出力する

```
$ sadf -t -s 19:00 -e 20:00 -j -- -A 2>&1

# ファイルを指定する
$ sadf /tmp/sar.data -t -j -- -A 2>&1
```
