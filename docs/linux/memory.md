# メモリ

## vmstat
``` bash
$ vmstat
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 1  0    736 6376312 384324 7006248    0    0     6   263  120  102 10  2 89  0  0

$ vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 2  0    736 6244880 384288 7006204    0    0     6   264  119  101 10  2 89  0  0
 0  0    736 6245036 384288 7006236    0    0     0     0  269  611  1  0 99  0  0
 0  0    736 6245548 384288 7006236    0    0     0     0  304  604  1  0 99  0  0
```


## メモリの情報
/proc/meminfo
/proc/sys/vm/...


## buddy
``` bash
$ cat /proc/buddyinfo
Node 0, zone      DMA      1      1      1      0      2      1      1      0      1      1      3
Node 0, zone    DMA32   9276   8187   5462   4087   2933   1747   1017    496      0      1      0
Node 0, zone   Normal  30524  27278  18196  12642   9484   6169   3571   2064    638      0      0
```


## kswapd



## malloc()


## kmalloc()


