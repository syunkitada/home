# メモリ

## 用語
| 用語 | 説明 |
| --- | --- |
| VSS(virtual set size)      | 仮想メモリ(mmapで確保して領域) |
| RSS(resident set size)     | 物理メモリの消費量(プロセスが仮想メモリにアクセスしてページフォールトが発生して割り当てられる実メモリ量） |
| PSS(proportional set size) | プロセスが実質的に所有しているメモリ |
| USS(unique set size)       | 一つのプロセスが占有しているメモリ |


## ページとデマンドページング
メモリーを「ページ」と呼ばれる単位で管理している
Linuxでは基本的に4Kバイトのページサイズを使用します。4Kバイト単位でメモリーページをプロセスに割り当てている。
プロセスは、メモリが必要になるとＯＳにmmapを発行し、仮想アドレスの使い方（処理方法）をしていする。
それを受けてＯＳは新たな仮想アドレス域をプロセスに割り当てる
この仮想アドレスにプロセスがアクセスすると、まだページが存在しない場合、ページフォールトという例外が発生する。
OSは、ぷーざープログラムのアクセス先を調べて、mmapによって得た仮想アドレス息の場合には先ほどのmmapの指定に従ってメモリを割り当てる
この実際に割り当てられたものがＲＳＳ
このような実際にメモリーが必要になった際に動的にメモリーを割り当てる方法を「デマンドページング」という。

もし、アクセス先を調べた際に、mmapによって得た仮想アドレス領域だった場合には、セグメンテーションフォルトと呼ぶ例外が発生し、ＯＳはプロセスにシグナル(SIGSEGV)を送信する
OSでは対応できないので、プロセス側に処理を決めてもらる、たいていのプロセスはこれを受け取ると終了する


## file mapとanon
VSZ, RSSに含まれるメモリーは、file map域とanonymous域に大別されます。
file map域はファイルの内容をメモリに張り付けた領域
anonymouse域はファイルとは無関係の領域

file map域はプログラムや共有ライブラリ、データファイルなどをメモリー張り付ける際に使用
anonymous域はヒープ(mallocでえられるメモリー）やスタックに使います

numa_mapという機能が追加されてプロセスのメモリーマップ状態を詳しく確認できるようになってます
``` bash
# cat自体のプロセスマップ
# file=... がfile_map域
# 名前がないのがanonyous域
# mapped=, anon= はページフォルトの発生によりマップされたページ数を表しています
# file_mapなのにanonがカウントされてる個所は、ファイルの中身をanonymouse域にコピーしてから、マッピングしていることを表している
# ファイルを読むだけなら、ファイルをメモリにマップして読めばいい、しかし、プライベートの書き込みを行う場合は、そのまま書き込むとファイルを変更してしまうので、いったんanonymousuにコピーして、コピー先に書き込む
#このような、「書き込み時にコピーする」ような仕組みをCopy On Write(COW)と呼ぶ、COWはメモリに限らずファイルシステムにおけるスナップショットや仮想マシンイメージ(qcow2など)にも利用されている

# ファイルに対して書き込みを行う場合、
$ cat /proc/self/numa_maps
00400000 default file=/usr/bin/cat mapped=7 N0=7 kernelpagesize_kB=4
0060b000 default file=/usr/bin/cat anon=1 dirty=1 N0=1 kernelpagesize_kB=4
0060c000 default file=/usr/bin/cat anon=1 dirty=1 N0=1 kernelpagesize_kB=4
0145f000 default heap anon=3 dirty=3 N0=3 kernelpagesize_kB=4
7f25e17da000 default file=/usr/lib/locale/locale-archive mapped=12 mapmax=7 N0=12 kernelpagesize_kB=4
7f25e7d03000 default file=/usr/lib64/libc-2.17.so mapped=83 mapmax=27 N0=83 kernelpagesize_kB=4
7f25e7eb9000 default file=/usr/lib64/libc-2.17.so
7f25e80b9000 default file=/usr/lib64/libc-2.17.so anon=4 dirty=4 N0=4 kernelpagesize_kB=4
7f25e80bd000 default file=/usr/lib64/libc-2.17.so anon=2 dirty=2 N0=2 kernelpagesize_kB=4
7f25e80bf000 default anon=3 dirty=3 N0=3 kernelpagesize_kB=4
7f25e80c4000 default file=/usr/lib64/ld-2.17.so mapped=27 mapmax=26 N0=27 kernelpagesize_kB=4
7f25e82da000 default anon=3 dirty=3 N0=3 kernelpagesize_kB=4
7f25e82e2000 default anon=1 dirty=1 N0=1 kernelpagesize_kB=4
7f25e82e3000 default file=/usr/lib64/ld-2.17.so anon=1 dirty=1 N0=1 kernelpagesize_kB=4
7f25e82e4000 default file=/usr/lib64/ld-2.17.so anon=1 dirty=1 N0=1 kernelpagesize_kB=4
7f25e82e5000 default anon=1 dirty=1 N0=1 kernelpagesize_kB=4
7ffca3575000 default stack anon=3 dirty=3 N0=3 kernelpagesize_kB=4
7ffca3598000 default
```

## メモリ回収
アプリケーションやカーネルはメモリが必要になると、メモリの割り当てをMMに要求する。
未使用のメモリーが十分にあれば、MMはそこからメモリーを割り当てます。
しかし、不十分な場合は、使用中のメモリを回収して割り当てようとする。
メモリーの回収とは使用中のメモリページを一つ一つ調べて、可能な場合にはそれを未使用の状態に戻す処理のこと。reclaim(回収)処理という。
MMは、2種類のreclaim処理を行う。
一つは、「background reclaim」、バックグラウンドで動き、kswapdというカーネルデーモンが、この処理を実行します。
kswapdは「Low」(低)「High」という2つの閾値をもっていて未使用メモリーの量がLowを下回ると起動し、Highを上回るまでreclaim処理を続ける

メモリーの割り当て要求の発行元に、セルフサービスでメモリー回収を行うように指示するdirect reclaim処理です。
direct reclaimそりでは、メモリーの割り当て要求をだしたスレッドがそのまま、reclaim処理を実施してメモリーを回収し、割り当てを試みます


## メモリ回収とは
reclaim処理ではページのリストがスキャンされる。
メモリの回収が可能か否かの判断
MMがアクセス履歴を調査し、ページが"最近"使われたように見える場合には回収しない仕組みになっている
スキャンが終わると、2巡、3巡目のスキャンに入る
メモリー獲得の勢いが強いとreclaim処理の実施サイクルが詰まって判定が頻繁に行われるようになります
その結果、"最近"という時間の長さがより短くなります。
メモリー回収方法は、ページがfileなのか、anonなのか、あるいはカーネルなのか、ページの内容によって異なります
ページがfileで、ファイルキャッシュとして使われている場合は、そのページをキャッシュの管理構造から外すことによってメモリを回収します。
場合によっては、キャッシュの内容をハードディスク（ＨＤＤ）に書き出す必要がある、その場合はIO処理が終わるのをまって回収する
ページがannon もすくはfileでユーザーメモリやtmpfsとして使われている場合は、その内容をswapに書き込むｋとによって追い出す。
追い出した後にデータが必要になった際は、swapの内容を読むことで対処する。
SLABと呼ばれるカーネルがメモリ上に作るオブジェクトの一部も解消の対象になる。
メモリ上のオブジェクトがどこからも参照されない状態になっていると、解放される。
また、何らかのキャッシュとして動作しているオブジェクトは、各自のアルゴリズムによって管理されており、必要に応じて回収処理が動作する。


active, inactiveのページリスト
1. anonは最初 acriveリストに追加される
2. fileはたいていの場合、最初はinactiveリストに追加される
3. reclaim処理でInactiveリストがスキャンされた際、ページがまだ使われてそうならAcriveリストにいれる、そうでなければ回収する
4. reclaim処理でAcriveリストがスキャンされた際、ページがまだ使われそうならリスト末尾に戻し、そうでなければInactiveリストに入れる


reclaim処理が走ると遅くなる
回収可能なメモリがほとんどなかったり、メモリー回収時にディスクへの書き込みが必要となり処理に時間がかかったりすることもある。
reclaim処理に時間がかかると、メモリ獲得処理で遅延が発生するのみならず、kswapdによってCPU負荷も増大する
このような状態が「メモリ不足」と呼ぶことが多い


メモリ不足を確認したり、予兆を把握するにはどうすればよいか？
/proc/meminfoで状況を把握

MemTotal: 実際に搭載されているDIMMの容量より少し少ない値になる(BIOSが使用する分や、メモリー管理が起動する前に使われた分など、OSのメモリー管理下にないメモリーが存在するため)
MemFree: 未使用メモリーの量、kswapdはこの量を監視して動作する
Buffers: 一時的にI/Oと紐づいている量
Cached: ファイルキャッシュ量(メモリー不足時にswapに追い出すべきtmpfsなどのページも含まれている)
ファイルキャッシュ量のうち、swapを使わない(swapに追い出せない)ページの合計は、
Active(file) + Inactive(file)
Active(file) + Inactive(anon)は、データをswapに追い出すべきページの容量です
後者にはプロセスで使用されているメモリーやtmpfs, 共有メモリーファイルが含まれます



fileとanonはそれぞれ、InactiveとActiveのリストを持っている
メモリ回収はInactiveリストから行われる
回収しにくいメモリはActiveリストに入れられる

Linuxには、プロセスがマップしているメモリーをreclaim処理の対象外にする(メモリーを固定する) mlock()というシステムコールがある。
回収対象になっていないメモリーは、meminfoのUnevictableという数値として示されており、reclaim処理はこれらを無視する
Mlocked: Mlockの量
```
Active:           985876 kB
Inactive:        1132072 kB
Active(anon):     491496 kB
Inactive(anon):   572156 kB
Active(file):     494380 kB
Inactive(file):   559916 kB
Unevictable:           0 kB
Mlocked:               0 kB
```

SLAB(カーネルメモリのうちSLABという定型のメモリアロケータを使うもの）の中で、reclaim処理の対象になるものがSreclaimableとして示される
大量のファイルに空くえせ酢するアプリケーションなどを動かすと、この値が増大することがある
SLABであっても回収できないものが、Sunreclaimに示される
```
Slab:              97980 kB
SReclaimable:      69008 kB
SUnreclaim:        28972 kB
```

なおswap域もいくつかメモリ上にキャッシュされていて、その量はSwapCachedとして表示される
これはInactive(anon)、Active(anon)の中に含まれる

メモリ不足かどうかの判断は困難

ただし、anonはswap freeがないと追い出せない

swapは十分にあるものの、ファイルキャッシュのいくらかは重要なデータなのでswapに追い出したくないと仮定すると、
MemFree + (Inactive(file) + Active(file)+Sreclaimable) * 0.7-0.9(係数はシステムに依存)
で算出される数字が、体感的には「空きメモリー」

ここでは、swapを考慮していないが、anonをswap域に追い出してもアクセスが生じなければ、性能への影響はないわけですし、逆にファイルキャッシュを捨てると性能が大きく低下することもある
swap域への追い出したり、ファイルキャッシュを捨てたりした場合の影響については、ケースバイケースで考える必要がある

ここにメモリ不足かどうかの判断における難しさがある
メモリー使用量で判断できないのなら、直近のメモリ料以外の統計情報（IO量やアプリケーションのレイテンシ、kswapdの稼働時間など）を加味して判断するしかない


メモリの自動監視
メモリの自動監視向けのインターフェイス[vmpressure]がカーネル3.10以降含まれている
reclaim処理が回収した量/reclaim処理がスキャンした量
の比を計算し、直近のメモリー回収にかかったコストがどの程度なのかを監視プログラム（デーモン)に通知する
この数値が下がるとメモリの使用状況が悪化したと判断し、カーネルから監視デーモンに通知を行います。
通知を受けた監視デーモンはアプリケーションにメモリを解散させたり、強制終了させたり、ネットワークデータのキャッシュを破棄したりして、未使用メモリ領域を増やそうとします

仮想マシンと連携してバルーニングする（ある仮想マシンからメモリを強制的に解放する)ことも考えられます。


anonは最初 Activeリストに追加される



## ライトバック
ファイルキャッシュについては、ディスクに書き戻してから回収する
このディスクに書き戻す処理をライトバックと呼ぶ
ライトバックのアルゴリズムや設定がアプリケーション性能に大きく影響する

ファイルキャッシュとライトバック
データをCPUの近く（高速にアクセスできる場所）に置くことを「キャッシュする」という
キャッシュにデータがあるとread()はディスクアクセスを回避できる
書き込み時write()はキャッシュに書き、キャッシュからディスクへ適宜ライトバックされる

キャッシュ上のデータを改変した場合、それをストレージに反映させる処理が必要になる（これをライトバックと呼ぶ）
キャッシュ上で改変されたためにストレージにライトバックする必要があるものを「ダーティーなキャッシュ」と呼ぶ。
ライトバックしなくてよいものを「クリーンなキャッシュ」と呼びます。
Linuxのライトバックでは、プロセスによるキャッシュへの書き込み速度とカーネルによるストレージへの書き込み速度を観測し、
その結果をもとにプロセスによるキャッシュへの書き込み速度やライトバック頻度を調整している。

書き込み速度を調整するわけ
空きメモリーができるだけキャッシュとして有効に使われつつ、かつメモリー獲得処理の邪魔にならないように、うまくコントロールする必要がある。
メモリ獲得時に未使用のメモリが少ないと、ファイルキャッシュの追い出しｇた必要になることがあります。
そしてキャッシュの追い出しをするには、キャッシュの情報がストレージに反映されている状態（クリーンな状態）であることが必要

ライトバックの問題点
ライトバック自体の処理にメモリが必要なこと
ストレージへのI/O発行にメモリーが必要ですし、NFSなどではネットワーク通信にメモリが必要
クリーンなページ、つまりすぐにReclaim処理ができるページを安定した量確保しておくことは、メモリ獲得処理が安定して動作することにつながる

メモリがダーティなものばかりになると、I/Oを特に行っていないプロセスまで、I/Oを発行しているプロセスの影響を受けがちなことです。
このような状態になると、I/Oをしていないプロセスでもメモリ獲得時のReclaim処理でライトバックのためのI/O待ちで遅延することがある。

ライトバック速度を調整するための設定値
* background dirty raito
    ライトバックを行うカーネルスレッド「flusher」を起動するしきい値
    システムの「回収可能なメモリー」に対して、ダーティーなキャッシュの比率がbackground dirty raitoを超えた場合にカーネルスレッドを起動する
    カーネルスレッドの起動タイミングは、この数値が小さいと早めに、大きいと遅めになる
* dirty raito
    システム上のダーティメモリ量を制限する閾値です。
    回収可能なメモリに対して、ダーティなキャッシュの比率がこの値を超えないように、write()を行うプログラムの速度を調整します。
    このdirty raitoの挙動はカーネル3.2から大きく変更された
    カーネル3.1以前の動作はwrite()発行時にダーティ量とdirty raitoを比較し、dirty raitoを上回っている場合はwrite()をしばらく止めて寝かせる
        一定のところまでは好きなだけ書かせておいて一定値まで到達したらいきなり（ひょっとしたら長時間）寝ることになる
    3.2以降は、ダーティの量が増加するにしたがってこまめにwaitを入れ、write()の速度をコントロールするようになっている
        これにより従来よりもwrite0を行うアプリケーションが「長く寝る」ことが少なくなっている

    3.1以前は閾値にぶつかったところで、メモリ管理から直接ライトバック処理を呼び出す処理が動作し、こうれが効率的なI/Oを阻害する要因になっていた
    3.2以降は、この処理が取り除かれて、I/Oは基本的にflusherスレッドが行うため、従来よりも効率的にI/Oを行えるようになった

    タスクごとなどにコントロール
    dirty raitoにはタスクごとのコントロールやブロックデバイスごとの設定項目もある
    /var/logのあるブロックデバイスのdirty raito制限を緩和し、遅くてdirtyがたまりがちなUSBドライブのdirty raitoを下げるといった設定が可能
    これらのチューニングでダーティ・ライトバック量を制御することでメモリ獲得コストや一度に出るI/Oの量を下げてシステムの安定性を高められる可能性がある




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


## hugetlb



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


## slub
* カーネルは、メモリの利用効率を高めるために、カーネル空間内のさまざまな メモリ資源を、資源ごとにキャッシュしている領域
* もし、slubのメモリが断片化してしまうとパフォーマンスにも影響が出てくる
* スラブの利用量はslubtopで確認できる

```
Active / Total Objects (% used)    : 1343215 / 1352019 (99.3%)
 Active / Total Slabs (% used)      : 35104 / 35104 (100.0%)
 Active / Total Caches (% used)     : 66 / 98 (67.3%)
 Active / Total Size (% used)       : 193251.77K / 194863.62K (99.2%)
 Minimum / Average / Maximum Object : 0.01K / 0.14K / 15.88K

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
295152 295152 100%    0.10K   7568       39     30272K buffer_head
238770 238620  99%    0.19K  11370       21     45480K dentry
150848 148349  98%    0.06K   2357       64      9428K kmalloc-64
128860 127969  99%    0.02K    758      170      3032K fsnotify_event_holder
125696 124665  99%    0.03K    982      128      3928K kmalloc-32
 98304  97251  98%    0.01K    192      512       768K kmalloc-8
 69003  68498  99%    0.08K   1353       51      5412K selinux_inode_security
 58368  58368 100%    0.02K    228      256       912K kmalloc-16
```



## 物理
* SPD
    * Serial Presence Detect
    * PCやサーバーを起動するさいに、メモリモジュールの情報をBIOSに伝える規格/仕組み
    * SPDデータ(メモリモジュールの情報)
        * メーカ名、規格、容量、搭載DRAM(CHIP)の情報(メーカー名・規格・bit構成・容量)、動作クロック周波数、CAS Latnecy(Column Address Strobe Latency)、動作電圧、ECC(誤り訂正符号)などのが含まれる
    * SPDデータはEEPROM(Electrically Erasable Programmable Read Only Memory)と呼ばれるモジュールに保存される
        * ライトプロテクトの機能が搭載されている
        * データの書き換えには専用の機器が必要
