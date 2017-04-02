# メモリ

## 用語
| 用語 | 説明 |
| --- | --- |
| VSS(virtual set size)      | 仮想メモリ(mmapで確保して領域) |
| RSS(resident set size)     | 物理メモリの消費量(プロセスが仮想メモリにアクセスしてページフォールトが発生して割り当てられる実メモリ量） |
| PSS(proportional set size) | プロセスが実質的に所有しているメモリ |
| USS(unique set size)       | 一つのプロセスが占有しているメモリ |

## 物理メモリ
L1キャッシュでのアクセスミスは数10クロックのペナルティが生じる
L2キャッシュでのアクセスミスは数10バスクロックのペナルティが生じる

キャッシュに読み込まれるタイミング
* アプリケーションが参照したメモリの内容がキャッシュにない場合
* アプリケーションがメモリに書き込みを行った内容がキャッシュにない場合
* アプリケーションがプリフェッチ命令を実行した場合
* ハードウェア・プリフェッチャーが動作した場合
読み込み書き込みの最小単位はキャッシュライン（64バイト）

| バンド幅 | |
| ストライド幅 | チャンクサイズ／ブロックサイズ(4KB) |
| ストライプ幅 | データディスク数×ストライド |
| レイテンシ | |

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


## pmap -x [PID]
メモリにはfile mapとanonがある
file mapはプログラムファイルや共有ライブラリタの内容を読み込んだメモリ領域
anonymouseはファイルとは無関係の領域で、ヒープ（mallocで得られるメモリ）やスタックに使う
``` bash
$ sudo pmap -x 23572
[sudo] password for owner:
23572:   /usr/bin/qemu-system-x86_64 -name centos7 -S -machine pc-i440fx-trusty,accel=kvm,usb=off -cpu Nehalem,+invpcid,+erms,+fsgsbase,+abm,+rdtscp,+pdpe1gb,+rdrand,+osxsave,+xsave,+tsc-deadline,+movbe,+pcid,+pdcm,+xtpr,+tm2,+est,+vmx,+ds_cpl,+monitor,+dtes64,+pclmuldq,+pbe,+tm,+ht,+ss,+acpi,+ds,+vme -m 12192 -realtime mlock=off -smp 2,sockets=2,cores=1,threads=1 -uuid ab775a1c-10cc-5010-7523-010f517993ed -nographic -no-user-config -nodefaults -chardev socket,id=charmonitor,path=/var/lib/libvirt/qemu/centos7.moni
Address           Kbytes     RSS   Dirty Mode  Mapping
00007fcc32000000 12484608 8425204 8418308 rw---   [ anon ]
00007fcf2c000000    1240     136     100 rw---   [ anon ]
00007fcf2c136000   64296       0       0 -----   [ anon ]
...
00007fcf4a160000    4800    1588       0 r-x-- qemu-system-x86_64
00007fcf4a810000     896      44      44 r---- qemu-system-x86_64
00007fcf4a8f0000     324      24      24 rw--- qemu-system-x86_64
...
```

## hugepage
http://dpdk.org/doc/guides-16.04/sample_app_ug/vhost.html
https://access.redhat.com/documentation/ja-JP/Red_Hat_Enterprise_Linux/7/html/Virtualization_Tuning_and_Optimization_Guide/sect-Virtualization_Tuning_Optimization_Guide-Memory-Tuning.html

```
# デフォルトを確認
$ cat /proc/meminfo
AnonHugePages:     81920 kB
HugePages_Total:    2048
HugePages_Free:     2048
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB

# hugepage を1G * 8page 確保
$ sudo vim /etc/default/grub
GRUB_CMDLINE_LINUX="hugepagesz=1G hugepages=8"

$ sudo grub-mkconfig -o /boot/grub/grub.cfg
$ reboot

# 確認
$ cat /proc/meminfo
AnonHugePages:     53248 kB
HugePages_Total:      13
HugePages_Free:       13
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:    1048576 kB

# hugepageサイズ
$ cat /proc/sys/vm/nr_hugepages
13

$ vim /etc/fstab
hugetlbfs   /mnt/huge   hugetlbfs defaults,pagesize=1G 0 0

$ sudo mount -a

# mount確認
# デフォルトで、kvmも/run/hugepages/kvm にhugetlbfsをマウントしてるマウントしてる？
$ mount
hugetlbfs-kvm on /run/hugepages/kvm type hugetlbfs (rw,mode=775,gid=125)
hugetlbfs on /mnt/huge type hugetlbfs (rw,pagesize=1G)

# hugepageをバッキングメモリにして2GのVMを起動すると、hugepageから確保される
$ sudo pmap 5150
5150:   /usr/bin/qemu-system-x86_64 -name centos7 -S -machine pc-i440fx-trusty,accel=kvm,usb=off -cpu Nehalem,+invpcid,+erms,+fsgsbase,+abm,+rdtscp,+pdpe1gb,+rdrand,+osxsave,+xs
ave,+tsc-deadline,+movbe,+pcid,+pdcm,+xtpr,+tm2,+est,+vmx,+ds_cpl,+monitor,+dtes64,+pclmuldq,+pbe,+tm,+ht,+ss,+acpi,+ds,+vme -m 1954 -mem-prealloc -mem-path /run/hugepages/kvm/l
ibvirt/qemu -realtime mlock=off -smp 2,sockets=1,cores=2,threads=1 -uuid 2c28f6ae-5fb4-11e6-95b5-cce1d540d3fa -nographic -no-user-config -nodefaults -chardev socket
00007f8980000000 2097152K rw--- qemu_back_mem.pc.ram.ZedopK (deleted)
00007f8a34000000   1144K rw---   [ anon ]
0

```



## /proc/[PID]/smaps
```
$ sudo cat /proc/23572/smaps | less
7fcc32000000-7fcf2c000000 rw-p 00000000 00:00 0
Size:           12484608 kB
Rss:             8429404 kB
Pss:             5329099 kB
Shared_Clean:        528 kB
Shared_Dirty:    3487568 kB
Private_Clean:      6388 kB
Private_Dirty:   4934920 kB
Referenced:      8257668 kB
Anonymous:       8429404 kB
AnonHugePages:   1107968 kB
Swap:            1996964 kB
KernelPageSize:        4 kB
MMUPageSize:           4 kB
Locked:                0 kB
VmFlags: rd wr mr mw me dc ac sd hg mg
7

# 2Gなので2ページ分消費された
$ cat /proc/meminfo
HugePages_Total:      13
HugePages_Free:       11
HugePages_Rsvd:        0
HugePages_Surp:        0
```



## kswapd



## malloc()


## kmalloc()


